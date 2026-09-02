#!/usr/bin/env python3
"""Captive portal watcher.

Opens a login window when a systemd-networkd link comes up behind a captive
portal.

Detection reads networkd's own CaptivePortal field (RFC 8910: DHCP option 114
or IPv6 RA), via org.freedesktop.network1.Link.Describe(). This is per-link and
authoritative. The previous version ran an unbound connectivity probe, which
follows the default route -- so with a second, lower-metric link present (a USB
ethernet dongle, say) it reported on that link instead and never noticed the
portal on the link that had just come up.
"""

import json
import re
import socket
import subprocess
import sys

from gi.repository import Gio, GLib

WEBVIEW = "/home/maxim/.local/bin/captive-portal-webview.py"
NETWORKD = "org.freedesktop.network1"
LINK_IFACE = "org.freedesktop.network1.Link"
MANAGER_PATH = "/org/freedesktop/network1"

# Per-interface record of the portal we last opened a window for, so the window
# is not reopened on every carrier flap (moving trains re-associate constantly).
shown = {}
child = None


def log(msg):
    print(msg, flush=True)


def link_name(path):
    """Interface name from a networkd object path, e.g. .../link/_33 -> wlan0.

    networkd hex-escapes leading characters that D-Bus forbids at the start of
    a path element, so ifindex 3 becomes '_33' and 13 becomes '_313'.
    """
    leaf = path.rsplit("/", 1)[-1]
    idx = re.sub(r"_([0-9a-fA-F]{2})", lambda m: chr(int(m.group(1), 16)), leaf)
    return socket.if_indextoname(int(idx))


def describe(bus, path):
    ret = bus.call_sync(NETWORKD, path, LINK_IFACE, "Describe", None,
                        GLib.VariantType("(s)"), Gio.DBusCallFlags.NONE,
                        5000, None)
    return json.loads(ret.unpack()[0])


def user_portal_url(capport, ifname):
    """Resolve the RFC 8908 capport API to the human-facing login page.

    The CaptivePortal field points at a JSON API endpoint, not a page a person
    can log in on. Ask it for 'user-portal-url'. Bound to the interface, since
    the portal host is only reachable through the captive link. Falls back to
    the API URL if that fails -- better to open something than nothing.
    """
    try:
        out = subprocess.run(
            ["curl", "-s", "-m", "4", "--interface", ifname,
             "-H", "Accept: application/captive+json", capport],
            capture_output=True, text=True, check=False).stdout
        url = json.loads(out).get("user-portal-url")
        if url:
            return url
        log(f"  capport API gave no user-portal-url, using {capport}")
    except Exception as e:
        log(f"  capport API unreachable ({e.__class__.__name__}), using {capport}")
    return capport


def open_portal(capport, ifname):
    global child
    if shown.get(ifname) == capport:
        return
    if child and child.poll() is None:
        log(f"{ifname}: portal window already open, not opening another")
        shown[ifname] = capport
        return
    url = user_portal_url(capport, ifname)
    log(f"{ifname}: captive portal -> opening {url}")
    child = subprocess.Popen([WEBVIEW, url])
    shown[ifname] = capport


def check(bus, path, state=None):
    ifname = link_name(path)
    try:
        info = describe(bus, path)
    except GLib.Error as e:
        log(f"{ifname}: Describe failed: {e.message}")
        return
    state = state or info.get("OperationalState")
    capport = info.get("CaptivePortal")
    if capport and state == "routable":
        open_portal(capport, ifname)
    elif not capport and ifname in shown:
        # Portal gone (logged in, or moved to a clean network). Forget it so a
        # future portal on this link opens a window again.
        log(f"{ifname}: no longer behind a portal")
        del shown[ifname]


def on_signal(conn, sender, path, iface, signal, params, user_data):
    changed_iface, props, _ = params.unpack()
    if changed_iface != LINK_IFACE:
        return
    state = props.get("OperationalState")
    if state is None:
        return
    # CaptivePortal arrives with the DHCP lease, which can land just after the
    # link reports routable -- so re-check shortly after as well as now.
    check(conn, path, state)
    if state == "routable":
        GLib.timeout_add_seconds(3, lambda: (check(conn, path), False)[1])


def initial_scan(bus):
    """Catch links already behind a portal when the service starts."""
    links = bus.call_sync(NETWORKD, MANAGER_PATH,
                          f"{NETWORKD}.Manager", "ListLinks", None,
                          GLib.VariantType("(a(iso))"), Gio.DBusCallFlags.NONE,
                          5000, None).unpack()[0]
    for _idx, _name, path in links:
        check(bus, path)


def main():
    bus = Gio.bus_get_sync(Gio.BusType.SYSTEM, None)
    bus.signal_subscribe(NETWORKD, "org.freedesktop.DBus.Properties",
                         "PropertiesChanged", None, LINK_IFACE,
                         Gio.DBusSignalFlags.NONE, on_signal, None)
    initial_scan(bus)
    log("watching for captive portals")
    GLib.MainLoop().run()


if __name__ == "__main__":
    sys.exit(main())
