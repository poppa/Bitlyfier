/* mainwindow.vala
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

using Gtk;

/**
 * The application main window
 */
public class Bitlyfier.MainWindow : GLib.Object
{
  Builder     builder;
  Window      win;
  Button      btn_convert;
  Entry       e_url;
  RadioButton rb_shorten;
  RadioButton rb_expand;
  Statusbar   sbar;
  StatusIcon  tray;

  public void init() throws Bitlyfier.Error
  {
    builder = new Builder();
    var ui = get_resource("windows.ui");
    if (ui == null) {
      throw new Bitlyfier.Error.GENERIC(
        _("Unable to locate user interface file!"));
    }

    try {
      builder.set_translation_domain(Config.GETTEXT_PACKAGE);
      builder.add_from_file(ui);
    }
    catch (GLib.Error e) {
      throw new Bitlyfier.Error.GENERIC(_("GUI load error: %s"), e.message);
    }

    win              = (Window)        g("mainwindow");
    btn_convert      = (Button)        g("btn_convert");
    e_url            = (Entry)         g("e_url");
    rb_shorten       = (RadioButton)   g("rb_shorten");
    rb_expand        = (RadioButton)   g("rb_expand");
    sbar             = (Statusbar)     g("statusbar");
    tray             = (StatusIcon)    g("tray");

    win.destroy += () => { Gtk.main_quit(); };
    win.window_state_event += on_window_state_changed;

    btn_convert.clicked += () => {
      if (rb_shorten.active)
        shorten_url();
      else
        expand_url();
    };
    rb_shorten.active = true;
    
    ((ImageMenuItem) g("menu_quit")).activate += () => {
      Gtk.main_quit();
    };
    
    ((ImageMenuItem) g("menu_about")).activate += on_about_clicked;
    ((ImageMenuItem) g("menu_settings")).activate += () => {
      try { new SettingsForm().run(); }
      catch (Bitlyfier.Error e) {
        message("%s", e.message);
      }
    };
    
    tray.tooltip_text = _("Click to show Bitlyfier");
    tray.activate += () => {
      win.visible = true;
      tray.visible = false;
    };
    
    win.set_size_request(460, 140);
    win.show_all();
    Gtk.main();
  }

  /**
   * Shortcut for getting a Gtk object fron the Glade file
   *
   * @param name
   * @return
   *  The Gtk object
   */
  GLib.Object g(string name)
  {
    return builder.get_object(name);
  }
  
  /**
   * Callback for when the window is minimized or maximized
   *
   * @param widget
   * @param event
   */
  bool on_window_state_changed(Window widget, Gdk.EventWindowState event)
  {
    Gdk.WindowState ico = Gdk.WindowState.ICONIFIED;
    Gdk.WindowState max = Gdk.WindowState.MAXIMIZED;

    if (event.changed_mask == ico && (
        event.new_window_state == ico ||
        event.new_window_state == (ico | max)))
    {
      win.hide();
      tray.visible = true;
    }
    return true;
  }
  
  /**
   * Shortens the URL
   *
   * @param widget
   */
  void shorten_url()
  {
    string url = e_url.text;
    string title = _("Shorten URL");

    if (url.length < "ftp://ab.cd".length) {
      error_dialog(_("The URL \"%s\" is too short!".printf(url)), title);
      return;  
    }

    if (!url.contains("://")) {
      var m = _("The URL \"%s\"contains no schema (e.g. http://domain.com)");
      error_dialog(m.printf(url), title);
      return;
    }
    
    set_status();

    Idle.add(() => {
      try {
        Bitly.Response res = api.shorten(url);
        e_url.text = res.get_string("shortUrl");
        rb_expand.active = true;
      }
      catch (Bitly.Error e) {
        error_dialog(_("An error occured: %s").printf(e.message), title);
      }
      catch (GLib.Error e) {
        error_dialog(_("An error occured: %s").printf(e.message), title);
      }

      reset_status();
      return false;
    });
  }

  /**
   * Expands the URL
   *
   * @param widget
   */
  void expand_url()
  {
    string url = e_url.text;
    string title = _("Expand URL");
    
    if (url.length < 5) {
      error_dialog(_("The URL \"%s\" is too short").printf(url), title);
      return;
    }
    
    if (url.contains("/") && 
        url.substring(0, "http://bit.ly".length) != "http://bit.ly")
    {
      var m = _("The URL \"%s\" doesn't start with http://bit.ly");
      error_dialog(m.printf(url), title);
      return;
    }
    
    set_status();

    Idle.add(() => {
      try {
        Bitly.Response res = api.expand(url);
        e_url.text = res.get_string("longUrl");
        rb_shorten.active = true;
      }
      catch (Bitly.Error e) {
        error_dialog(_("An error occured: %s").printf(e.message), title);
      }
      catch (GLib.Error e) {
        error_dialog(_("An error occured: %s").printf(e.message), title);
      }

      reset_status();
      return false;
    });
  }
  
  /**
   * Set the statusbar to working
   */
  void set_status()
  {
    sbar.push(0, _("Working..."));
  }

  /**
   * Set the statusbar to done
   */
  private void reset_status()
  {
    sbar.push(0, _("Done"));
  }
  
  /**
   * Callback for the About menu item. Opens the About dialog
   */
  void on_about_clicked()
  {
    var d = new AboutDialog();
    try {
      d.logo = new Gdk.Pixbuf.from_file(get_resource("bitlyfier-about.png"));
      d.icon = new Gdk.Pixbuf.from_file(get_resource("bitlyfier-small.png"));
    }
    catch (GLib.Error e) {}

    d.program_name = "Bit.ly.fier";
    d.set_version(Config.VERSION);
    d.authors = { "Pontus Östlund <pontus@poppa.se>", null };
    d.set_license(
      "BITLYFIER\n"                                                            +
      "Copyright © 2009 Pontus Östlund\n"                                      +
      "\n"                                                                     +
      "This program is free software: you can redistribute it and/or modify\n" +
      "it under the terms of the GNU General Public License as published by\n" +
      "the Free Software Foundation, either version 3 of the License, or\n"    +
      "(at your option) any later version.\n"                                  +
      "\n"                                                                     +
      "This program is distributed in the hope that it will be useful,\n"      +
      "but WITHOUT ANY WARRANTY; without even the implied warranty of\n"       +
      "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n"         +
      "GNU General Public License for more details.\n"                         +
      "\n"                                                                     +
      "You should have received a copy of the GNU General Public License\n"    +
      "along with this program. If not, see <http://www.gnu.org/licenses/>."
    );
    d.copyright = "Copyright © 2010 Pontus Östlund";
    d.website = "http://poppa.se";
    d.website_label = "www.poppa.se";
    d.comments = _("Bitlyfier lets you shorten and expand links (URLs) via"    +
                   "\nBit.ly - a service that allowes users to shorten, "      +
                   "share\nand track links");  
    d.run();
    d.destroy();
  }

  /**
   * Creates an error dialog
   *
   * @param message
   * @param title
   */
  private void error_dialog(string message, string? title=null)
  {
    var d = new MessageDialog(
      this.win, DialogFlags.DESTROY_WITH_PARENT, MessageType.ERROR,
      ButtonsType.OK, "%s", message
    );
    d.title = title == null ? _("Error") : title;
    d.run();
    d.destroy();
  }
}

/**
 * The settings dialog
 */
public class Bitlyfier.SettingsForm : GLib.Object
{
  Builder     builder;
  Dialog      dialog;
  Entry       e_username;
  Entry       e_apikey;
  CheckButton cb_history;
  Label       lb_username;
  Label       lb_apikey;
  Button      btn_ok;
  Button      btn_cancel;

  public SettingsForm() throws Bitlyfier.Error
  {
    builder = new Builder();
    var ui = get_resource("windows.ui");
    if (ui == null) {
      throw new Bitlyfier.Error.GENERIC(
        _("Unable to locate user interface file!"));
    }

    try {
      builder.set_translation_domain(Config.GETTEXT_PACKAGE);
      builder.add_from_file(ui);
    }
    catch (GLib.Error e) {
      throw new Bitlyfier.Error.GENERIC(_("GUI load error: %s"), e.message);
    }

    dialog      = (Dialog)      g("settings");
    e_username  = (Entry)       g("e_username");
    e_apikey    = (Entry)       g("e_apikey");
    cb_history  = (CheckButton) g("cb_history");
    lb_username = (Label)       g("lb_username");
    lb_apikey   = (Label)       g("lb_apikey");
    btn_ok      = (Button)      g("btn_ok");
    btn_cancel  = (Button)      g("btn_cancel");

    e_username.text   = not_null(settings.username);
    e_apikey.text     = not_null(settings.apikey);
    cb_history.active = settings.history;

    btn_cancel.clicked.connect(() => {});
    btn_ok.clicked.connect(() => {});
  }
  
  string not_null(string? s)
  {
    if (s == null) return "";
    return s;
  }
  
  /**
   * Run the dialog
   */
  public int run()
  {
    int response = dialog.run();
    if (response == ResponseType.OK) {
      settings.username = e_username.text;
      settings.apikey   = e_apikey.text;
      settings.history  = cb_history.active;

      if (api != null) {
        api.username = e_username.text;
        api.apikey   = e_apikey.text;
        api.history  = cb_history.active;
      }
    }

    dialog.destroy();
    return response;
  }
  
  /**
   * Shortcut for getting a Gtk object fron the Glade file
   *
   * @param name
   * @return
   *  The Gtk object
   */
  GLib.Object g(string name)
  {
    return builder.get_object(name);
  }
}
