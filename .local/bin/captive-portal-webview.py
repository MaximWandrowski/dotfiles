#!/usr/bin/env python3
import gi, sys
gi.require_version("Gtk", "4.0")
gi.require_version("WebKit", "6.0")
from gi.repository import Gtk, WebKit

URL = sys.argv[1] if len(sys.argv) > 1 else "http://neverssl.com"

class App(Gtk.Application):
    def __init__(self):
        super().__init__(application_id="org.local.CaptivePortal")
    def do_activate(self):
        win = Gtk.ApplicationWindow(application=self, title="Captive Portal")
        win.set_default_size(900, 650)
        session = WebKit.NetworkSession.new_ephemeral()
        view = WebKit.WebView(network_session=session)
        view.load_uri(URL)
        win.set_child(view)
        win.present()

App().run([sys.argv[0]])
