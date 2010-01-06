/* (filename).vala
 *
 * Copyright (C) 2010  Pontus Östlund
 *
 * This library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author:
 * 	Pontus Östlund <pontus@poppa.se>
 */

using GConf;

namespace Bitlyfier
{
  errordomain Error {
    GENERIC;
  }

  public string? get_resource(string resource)
  {
    // The first two indices is for local usage during development
    string[] paths = { "ui", "src/ui", Config.DATADIR + "/bitlyfier/ui" };
    string full_path = null;

    foreach (string path in paths) {
      full_path = Path.build_filename(path, resource);
      if (file_exists(full_path))
        return full_path;
    }

    return null;
  }
  
  public bool file_exists(string file)
  {
    return FileUtils.test(file, FileTest.EXISTS);
  }

  public class Settings : GLib.Object
  {
    private GConf.Client gcli;
    const string ROOT = "/apps/bitlyfier/properties/";

    public string? username {
      get {
        try {
          return gcli.get_string(ROOT + "username");
        }
        catch (GLib.Error e) {
          warning("Unable to get GConf string \"username\"!");
          return null;
        }
      }
      set {
        try {
          gcli.set_string(ROOT + "username", value);
        }
        catch (GLib.Error e) {
          warning("Unable to set GConf string \"username\"!");
        }
      }
    }
 
    public string? apikey {
      get {
        try {
          return gcli.get_string(ROOT + "apikey");
        }
        catch (GLib.Error e) {
          warning("Unable to get GConf string \"apikey\"!");
          return null;
        }
      }
      set {
        try {
          gcli.set_string(ROOT + "apikey", value);
        }
        catch (GLib.Error e) {
          warning("Unable to set GConf string \"apikey\"!");
        }
      }
    }

    public bool history {
      get {
        try {
          return gcli.get_bool(ROOT + "history");
        }
        catch (GLib.Error e) {
          warning("Unable to get GConf bool \"history\"!");
          return true;
        }
      }
      set {
        try {
          gcli.set_bool(ROOT + "history", value);
        }
        catch (GLib.Error e) {
          warning("Unable to get GConf bool \"history\"!");
        }
      }
    }

    public Settings() throws GLib.Error
    {
      gcli = GConf.Client.get_default();
    } 
  }
}