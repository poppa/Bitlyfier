/* main.vala
 *
 * Copyright © 2010  Pontus Östlund
 *
 * Bitlyfier is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Bitlyfier is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this Bitlyfier.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author:
 * 	Pontus Östlund <pontus@poppa.se>
 */

Bitlyfier.MainWindow window;
Bitlyfier.Settings settings;
Bitly.Api api;

static string arg_expand;
static string arg_shorten;
static bool   arg_nogui;
static bool   arg_gconf;

const OptionEntry[] options = {
  { "expand", 'e',  OptionFlags.OPTIONAL_ARG, OptionArg.STRING, ref arg_expand,
    N_("Expands the given URL"), null },
  { "shorten", 's', OptionFlags.OPTIONAL_ARG, OptionArg.STRING, ref arg_shorten,
    N_("Shortens the given URL"), null },
  { "no-gui", 'n',  OptionFlags.OPTIONAL_ARG, OptionArg.NONE,   ref arg_nogui,
    N_("Sets the application in command line mode"), null },
  { "gconf", 'g',   OptionFlags.OPTIONAL_ARG, OptionArg.NONE,   ref arg_gconf,
    N_("Invokes setting username and apikey"), null },
  { null }
};

namespace Bitlyfier 
{
  public string gets()
  {
    return stdin.read_line().strip();
  }
}

int main (string[] args)
{
  Intl.setlocale(LocaleCategory.ALL,"");
  Intl.bindtextdomain(Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
  Intl.bind_textdomain_codeset(Config.GETTEXT_PACKAGE, "UTF-8");
  Intl.textdomain(Config.GETTEXT_PACKAGE);  

  try {
    var opt = new OptionContext(_("- Bitlyfier, URL shortener/expander"));
    opt.set_help_enabled(true);
    opt.add_main_entries(options, null);
    opt.parse(ref args);

    if (arg_nogui && !arg_gconf && (arg_expand == null && 
        arg_shorten == null)) 
    {
      stderr.printf(_("Missing required argument '-e' or '-s'")+"\n");
      stderr.printf("%s", opt.get_help(true, null));
      return -1;
    }
  }
  catch (Error e) {
    stderr.printf("%s\n", e.message);
    var m = _("Run '%s --help' to see a full list of available command " +
              "line options.");
    stderr.printf(m + "\n", args[0]);
    return 1;
  }
  
  try { settings = new Bitlyfier.Settings(); }
  catch (Error e) {
    stderr.printf("%s\n", e.message);
    return 1;
  }
  
  string uname  = settings.username;
  string apikey = settings.apikey;
  bool history  = settings.history;

  if (arg_nogui && !arg_gconf && (uname == null || apikey == null)) {
    stderr.printf(_("** No username or API-key for this application is set.\n" +
                    "** Run '%s --no-gui --gconf' to set the username and "    +
                    "API-key!") + "\n", args[0]);
    return 1;
  }

  if (arg_nogui && arg_gconf) {
    string v = null;
    stdout.printf("\n  "+_("* Leave fields empty to keep old values")+"\n\n"); 
    stdout.printf("  "+_("Write your username:")+" ");

    v = Bitlyfier.gets();
    if (v.length > 0)
      settings.username = v;
    
    stdout.printf("\n  "+_("Write your API-key:")+" ");
    v = Bitlyfier.gets();
    if (v.length > 0)
      settings.apikey = v;
      
    stdout.printf("\n  "+_("* History? If `1` links shortened by this "        +
                           "application will show up on your\n    statistics " +
                           "page at http://bit.ly and if `0` they will not.")  +
                           "\n\n");
    stdout.printf("  "+_("Use history:")+" ");

    v = Bitlyfier.gets();
    if (v == "1")
      settings.history = true;
    else if (v == "0")
      settings.history = false;

    stdout.printf("\n\n"+_("Values have been saved!")+"\n");
    return 0;
  }

  if (!arg_nogui && (uname == null || apikey == null)) {
    Gtk.init(ref args);
    try {
      var sd = new Bitlyfier.SettingsForm();
      if (sd.run() == Gtk.ResponseType.OK) {
        uname = settings.username;
        apikey = settings.apikey;
        history = settings.history;
      }
      else
        return 0;
    }
    catch (Error e) {
      stderr.printf("%s", e.message);
      return 0;
    }
  }

  api = new Bitly.Api(uname, apikey);
  api.history = history;

  if (arg_nogui) {
    try {
      Bitly.Response resp = null;
      if (arg_shorten != null) {
        resp = api.shorten(arg_shorten);
        stdout.printf(_("Short URL: %s")+"\n", resp.get_string("shortUrl"));
      }
      else if (arg_expand != null) {
        resp = api.expand(arg_expand);
        stdout.printf(_("Long URL: %s")+"\n", resp.get_string("longUrl"));
      }
      else {
        stderr.printf(_("Unknown service \"%s\"!")+"\n", args[1]);
        return 1;
      }
    }
    catch (Error e) {
      message("%s", e.message);
      return 1;
    }

    return 0;
  }

  Gtk.init (ref args);
  window = new Bitlyfier.MainWindow();
  try { window.init(); }
  catch (Error e) {
    stderr.printf("%s\n", e.message);
  }

  return 0;
}