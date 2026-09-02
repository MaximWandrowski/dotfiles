#!/usr/bin/env python3
from gi.repository import Gio, GLib
import subprocess

DETECT = "http://connectivitycheck.gstatic.com/generate_204"
WEBVIEW = "/home/maxim/.local/bin/captive-portal-webview.py"

def behind_portal():
    r = subprocess.run(
        ["curl", "-s", "-m", "5", "-o", "/dev/null", "-w", "%{http_code}", DETECT],
        capture_output=True, text=True)
    return r.stdout.strip() != "204"

def on_signal(conn, sender, path, iface, signal, params, user_data):
    changed_iface, props, _ = params.unpack()
    if changed_iface != "org.freedesktop.network1.Link":
        return
    if props.get("OperationalState") == "routable" and behind_portal():
        subprocess.Popen([WEBVIEW, "http://neverssl.com"])

bus = Gio.bus_get_sync(Gio.BusType.SYSTEM, None)
bus.signal_subscribe(
    "org.freedesktop.network1",
    "org.freedesktop.DBus.Properties",
    "PropertiesChanged",
    None,
    "org.freedesktop.network1.Link",
    Gio.DBusSignalFlags.NONE,
    on_signal,
    None
)
GLib.MainLoop().run()
