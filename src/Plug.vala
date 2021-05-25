/*
 * Copyright 2021 elementary, Inc
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

public class OnlineAccounts.Plug : Switchboard.Plug {
    private MainView main_view;

    public Plug () {
        var settings = new Gee.TreeMap<string, string?> (null, null);
        settings.set ("accounts/online", null);
        Object (
            category: Category.NETWORK,
            code_name: "io.elementary.switchboard.onlineaccounts",
            display_name: _("Online Accounts"),
            description: _("Manage online accounts and connected applications"),
            icon: "preferences-desktop-online-accounts",
            supported_settings: settings
        );
    }

    public override Gtk.Widget get_widget () {
        if (main_view == null) {
            Gtk.IconTheme.get_default ().add_resource_path ("/io/elementary/switchboard/onlineaccounts");

            main_view = new MainView ();
        }

        return main_view;
    }

    public override void shown () {
    }

    public override void hidden () {
    }

    public override void search_callback (string location) {
    }

    public override async Gee.TreeMap<string, string> search (string search) {
        var search_results = new Gee.TreeMap<string, string> (
            (GLib.CompareDataFunc<string>)strcmp,
            (Gee.EqualDataFunc<string>)str_equal
        );
        search_results.set ("%s → %s".printf (display_name, _("CalDAV")), "");
        search_results.set ("%s → %s".printf (display_name, _("Calendars")), "");
        search_results.set ("%s → %s".printf (display_name, _("IMAP")), "");
        search_results.set ("%s → %s".printf (display_name, _("Mail")), "");
        return search_results;
    }
}

public Switchboard.Plug get_plug (Module module) {
    var plug = new OnlineAccounts.Plug ();
    return plug;
}
