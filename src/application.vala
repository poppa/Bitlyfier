/* application.vala
 *
 * Copyright © 2010  Pontus Östlund
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

  /**
   * Tries to find the requested resource (file) in the UI directory. 
   * It first looks in "ui", then in "src/ui" and last in "/usr/local/...".
   * This useful during development so that we can get the local resources
   * rather than the installed ones.
   *
   * @param resource
   * @return
   *  The path to the resource or null it not found
   */ 
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
  
  /**
   * Checks if file exists or not
   *
   * @param file
   */
  public bool file_exists(string file)
  {
    return FileUtils.test(file, FileTest.EXISTS);
  }

  /**
   * The Settings class handles this applications GConf properties
   */
  public class Settings : GLib.Object
  {
    /**
     * The GConf client
     */
    private GConf.Client gcli;

    /**
     * The GConf root where the application properties will be saved
     */
    const string ROOT = "/apps/bitlyfier/properties/";

    /**
     * The Bit.ly user to log in as
     */
    public string? username {
      get {
        try { return gcli.get_string(ROOT + "username"); }
        catch (GLib.Error e) {
          warning("Unable to get GConf string \"username\"!");
          return null;
        }
      }
      set {
        try { gcli.set_string(ROOT + "username", value); }
        catch (GLib.Error e) {
          warning("Unable to set GConf string \"username\"!");
        }
      }
    }
 
    /**
     * The Bit.ly API key to use
     */
    public string? apikey {
      get {
        try { return gcli.get_string(ROOT + "apikey"); }
        catch (GLib.Error e) {
          warning("Unable to get GConf string \"apikey\"!");
          return null;
        }
      }
      set {
        try { gcli.set_string(ROOT + "apikey", value); }
        catch (GLib.Error e) {
          warning("Unable to set GConf string \"apikey\"!");
        }
      }
    }

    /**
     * The history property defines whether or not to display shortened links
     * by this application on the statistics page or not.
     */
    public bool history {
      get {
        try { return gcli.get_bool(ROOT + "history"); }
        catch (GLib.Error e) {
          warning("Unable to get GConf bool \"history\"!");
          return true;
        }
      }
      set {
        try { gcli.set_bool(ROOT + "history", value); }
        catch (GLib.Error e) {
          warning("Unable to get GConf bool \"history\"!");
        }
      }
    }

    /**
     * Creates a new Settings object
     */
    public Settings() throws GLib.Error
    {
      gcli = GConf.Client.get_default();
    } 
  }
}