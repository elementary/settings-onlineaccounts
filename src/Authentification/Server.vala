// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013-2015 Pantheon Developers (https://launchpad.net/switchboard-plug-onlineaccounts)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 *
 * Authored by: Corentin Noël <corentin@elementary.io>
 */

[DBus (name = "com.google.code.AccountsSSO.gSingleSignOn.UI")]
public class OnlineAccounts.UIServer : Object {
    [DBus (visible = false)]
    public UIServer (string bus_address) {
        this.bus_address = bus_address;
    }

    [DBus (visible = false)]
    public signal void handle_get_bus_address ();

    private string bus_address;

    [DBus (name = "getBusAddress")]
    public string get_bus_address () throws GLib.DBusError, GLib.IOError {
        handle_get_bus_address ();
        return bus_address;
    }
}

public class OnlineAccounts.Server : GLib.Object {
    const string BUS_NAME = "com.google.code.AccountsSSO.gSingleSignOn.UI";

    uint bus_owner_id = 0;
    GLib.DBusServer bus_server;
    string socket_file_path;
    int socket_file_id = 0;

    public Server () {
        bus_owner_id = GLib.Bus.own_name (GLib.BusType.SESSION, BUS_NAME,
             GLib.BusNameOwnerFlags.ALLOW_REPLACEMENT | GLib.BusNameOwnerFlags.REPLACE,
             on_bus_acquired, on_name_acquired, on_name_lost);
    }

    ~Server () {
        bus_server.stop ();
        GLib.Bus.unown_name (bus_owner_id);
    }

    void on_name_acquired (GLib.DBusConnection connection, string name) {
        debug ("D-Bus name acquired");
    }

    void on_name_lost (GLib.DBusConnection connection, string name) {
        debug ("D-Bus name lost");
    }

    void on_bus_acquired (GLib.DBusConnection connection, string name) {
        debug ("D-Bus bus acquired");

        var base_path = "%s/gsignond/".printf (GLib.Environment.get_user_runtime_dir ());
        socket_file_path = base_path + "ui-XXXXXX";
        socket_file_id = GLib.FileUtils.mkstemp (socket_file_path);
        debug ("Socket File path : %s", socket_file_path);
        var err_no = GLib.DirUtils.create_with_parents (base_path, 0700);
        if (err_no == -1) {
            warning ("Could not create '%s', error: %s", base_path, GLib.strerror (err_no));
        }

        GLib.FileUtils.unlink (socket_file_path);
        var address = "unix:path=%s".printf (socket_file_path);
        string guid = GLib.DBus.generate_guid ();
        try {
            bus_server = new GLib.DBusServer.sync (address, GLib.DBusServerFlags.RUN_IN_THREAD, guid);
        } catch (Error error) {
            warning ("Could not start dbus server at address '%s' : %s", address, error.message);
            socket_file_path = null;
            return ;
        }

        GLib.FileUtils.chmod (socket_file_path, 0600);
        bus_server.new_connection.connect (on_client_connection);

        /* expose interface */
        try {
            connection.register_object ("/", new UIServer (address));
        } catch (IOError e) {
            warning ("Failed to export interface: %s", e.message);
            return;
        }

        bus_server.start ();
        debug ("UI Dialog server started at : %s", bus_server.get_client_address ());
    }

    bool on_client_connection (DBusConnection connection) {
        try {
            var dialog_service = new DialogService ();
            connection.register_object ("/Dialog", dialog_service);
        } catch (IOError e) {
            warning ("Failed to export interface: %s", e.message);
            return false;
        }

        return true;
    }
}
