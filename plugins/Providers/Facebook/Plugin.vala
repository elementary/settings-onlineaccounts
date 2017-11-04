// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013 Pantheon Developers (http://launchpad.net/online-accounts-plug)
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
 * Authored by: Corentin Noël <tintou@mailoo.org>
 */
public class OnlineAccounts.Plugins.OAuth.Facebook.SubPlugin : OnlineAccounts.SubPlugin {
    
    public override void execute_function (string function_name, GLib.Object arg) {
        if (function_name == "get_user_name") {
            
            
        }
    }
    
    public override string get_name () {
        return subplugin_name;
    }
    
    public override string get_plugin_name () {
        return plugin_name;
    }
}
