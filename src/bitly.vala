/* bitly.vala
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

using Gee;
using Soup;

namespace Bitly
{
  errordomain Error {
    GENERIC;
  }

  public class Api
  {
    /**
     * Version of Bitly to use
     */
    const string VERSION = "2.0.1";
    const string FORMAT_XML = "xml";
    const string FORMAT_JSON = "json";
    const string BASE_URL = "http://api.bit.ly";
    
    public string username { get; set; }
    public string apikey { get; set; }
    public string version { get; private set; default = VERSION; }
    public string callback { get; private set; }
    public string format { get; set; default = FORMAT_JSON; }
    public bool history { get; set; default = true; } 

    /**
     * Creates a new instance of Bitly.Api
     *
     * @param username
     * @param apikey
     */
    public Api(string username, string apikey)
    {
      this.username = username;
      this.apikey = apikey;
    }

    /** 
     * Returns info about the page of the shortened URL, page title etc...
     *
     * @param url
     *  Either the shortened URL or its hash.
     * @param keys
     *  One or more keys to limit the attributes returned about each bitly 
     *  document, eg: htmlTitle,thumbnail
     */
    public Response? info(string _url, string[]? keys=null)
      throws Bitly.Error, GLib.Error
    {
      assert(format == FORMAT_JSON);
      
      var url = _url.dup().strip();
      
      HashMap<string,string> args = url_param(url);
      if (keys != null)
        args.set("keys", join_array(",", keys));

      string resp = call("info", args);
      Json.Object root = get_json_root(resp);

      Response res = null;

      if (root.get_size() > 0) {
        Json.Node node = root.get_member(url).copy();
        res = new Response(node.dup_object());
      }

      return res;
    }

    /** 
     * Shortens the long url
     *
     * @param url
     */
    public Response? shorten(string _url)
      throws Bitly.Error, GLib.Error
    {
      assert(format == FORMAT_JSON);

      var url = _url.dup().strip();

      string resp = call("shorten", url_param(url));
      Json.Object root = get_json_root(resp);
      Response res = null;
      if (root.get_size() > 0) {
        Json.Node node = root.get_member(url).copy();
        res = new Response(node.dup_object());
      }
      return res;
    }

    /** 
     * Expands a bitly shortened URL
     *
     * @param url
     */
    public Response? expand(string _url)
      throws Bitly.Error, GLib.Error
    {
      assert(format == FORMAT_JSON);
      
      var url = _url.dup().strip();
      
      string resp = call("expand", url_param(url));
      Json.Object root = get_json_root(resp);
      Response res = null;
      if (root.get_size() > 0) {
        unowned Json.Node tmp = root.get_member(url);
        Json.Node node = null;
        if (tmp != null)
          node = root.get_member(url).copy();
        else {
          GLib.List<unowned string> m = root.get_members();
          foreach (string k in m) {
            if ((tmp = root.get_member(k)) != null) {
              node = tmp.copy();
              break;  
            }
          }
        }
        res = new Response(node.dup_object());
      }

      return res;
    }
    
    /**
     * Returns traffic and referrer data of the shortened URL
     *
     * @param url_or_hash
     *  Either the shortened URL or its hash.
     */
    public Response? stats(string _url)
      throws Bitly.Error, GLib.Error
    {
      assert(format == FORMAT_JSON);

      var url = _url.dup().strip();

      string resp = call("stats", url_param(url));
      Json.Object root = get_json_root(resp);
      Response res = null;
      if (root.get_size() > 0) {
        //Json.Node node = root.get_member(url);
        res = new Response(root);
      }
      
      return res;
    }

    /**
     * Does the HTTP call to Bitly
     *
     * @param service
     * @param params
     */
    public string call(string service, HashMap<string,string> args)
      throws Bitly.Error, GLib.Error
    {
      string url = get_normalized_url(service);
      HashMap<string,string> params = new HashMap<string,string>();
      params.set("version", version);
      params.set("apikey", apikey);
      params.set("format", format);
      
      if (service == "shorten" && history)
        params.set("history", "1");

      if (args.size > 0)
        foreach (string k in args.keys)
          params.set(k, args[k]);

      string query = "";
      int i = 0;
      foreach (string k in params.keys) {
        query += k + "=" + params[k];
        if (i++ < params.size-1)
          query += "&";
      }
      
      url = url + "?" + query;

      var mess = new Message("GET", url);
      var sess = new SessionSync();

      mess.request_headers.append("Authorization",
                                  "Basic " + base64_encode(username+":"+apikey));
#if BITLY_DEBUG
      sess.add_feature = new Logger(LoggerLogLevel.BODY, -1);
#endif
      sess.send_message(mess);
    
      if (mess.status_code != 200)
        throw new Bitly.Error.GENERIC("Bad status (%ld) in response: %s".printf(
                                      mess.status_code, mess.reason_phrase));

      return mess.response_body.data;
    }

    /**
     * Creates either of the mandatory argumens "hash" or "longUrl".
     *
     * @param url
     */
    private HashMap<string,string> url_param(string url)
    {
      string ret = url.dup();
      HashMap<string,string> m = new HashMap<string,string>();
      string key = null;
      if (ret.contains("://")) {
        if (url.substring(0, "http://bit.ly".length) == "http://bit.ly")
          key = "shortUrl";
        else
          key = "longUrl";
      }
      else if (ret.length >= 6 && ret.substring(0, 6) == "bit.ly") {
        key = "longUrl";
        ret = "http://" + ret;  
      }
      else
        key = "hash";

      m.set(key, url);
      return m;
    } 
    
    /**
     * Returns the full normalized URL to the Bitly API
     *
     * @param service
     *  The service to call, e.g info, shorten, expand etc
     */
    private string get_normalized_url(string service)
    {
      string ret = service.dup();

      if (ret[0] != '/')
        ret = "/" + ret;
      if (ret[ret.length-1] == '/')
        ret.substring(0, ret.length-1);

      return BASE_URL + ret;
    }
    
    /**
     * Returns the "results" node as a Json object from the response string
     * If the response failed with statusCode "ERROR" an exception will be
     * thrown.
     *
     * @throws BitlyError
     * @throws GLib.Error
     * @param json_string
     * @return
     *  The "results" node as a Json.Object
     */
    private Json.Object get_json_root(string json_string)
      throws Bitly.Error, GLib.Error
    {
      var parser = new Json.Parser();
      parser.load_from_data(json_string, json_string.length);
      unowned Json.Object root = parser.get_root().get_object();
      string status = root.get_member("statusCode").get_string();

      if (status == "ERROR") {
        string m = root.get_member("errorMessage").get_string();
        int c = root.get_member("errorCode").get_int();
        throw new Bitly.Error.GENERIC("Bitly error (%d): %s".printf(c, m)); 
      }

      unowned Json.Node o = root.get_member("results");
      
      if (o.get_value_type().name() != "JsonObject")
        throw new Bitly.Error.GENERIC("Result is not a JSON object!");

      Json.Object obj = o.dup_object();
      return obj;
    }
  }

  public class Response : GLib.Object
  {
    Json.Object n = null;
    
    public Response(Json.Object object)
    {
      n = object;
    }

    public string? get_string(string key)
    {
      unowned Json.Node item = null;
      if (key.contains(".")) {
        if (find_node(key, out item) == "gchararray")
          return item.get_string();
      }
      else {
        if ((item = n.get_member(key)) != null) {
          if (item.get_value_type().name() == "gchararray")
            return item.get_string();
        }
      }
      return null;
    }
    
    public double get_double(string key)
    {
      unowned Json.Node item = null;
      if (key.contains(".")) {
        string t = find_node(key, out item);
        message("Found: %s", t);
      }
      else {
        if ((item = n.get_member(key)) != null) {
          if (item.get_value_type().name() == "gdouble")
            return item.get_double();
        } 
      }
      return 0;
    }
    
    public int get_integer(string key)
    {
      unowned Json.Node item = null;
      if (key.contains(".")) {
        string t = find_node(key, out item);
        message("Found: %s", t);
      }
      else {
        if ((item = n.get_member(key)) != null) {
          if (item.get_value_type().name() == "gint64")
            return item.get_int();
        } 
      }
      return 0;
    } 
    
    private string? find_node(string key, out unowned Json.Node node)
    {
      string[] parts = key.split(".");
      Json.Object tmp = n;
      unowned Json.Node item = null;

      foreach (string part in parts) {
        item = tmp.get_member(part);
        if (item != null) {
          if (item.get_value_type().name() == "JsonObject")
            tmp = item.dup_object();
        }
      }
      
      if (item != null) {
        node = item;
        return item.get_value_type().name();
      }
      
      return null;
    }
  }

  internal string base64_encode(string s)
  {
    uchar[] bytes = new uchar[s.length];
    for (int i = 0; i < bytes.length; i++)
      bytes[i] = (uchar)s[i];

    return Base64.encode(bytes);
  }

  internal string join_array(string glue, string[] array)
  {
    string ret = "";
    for (int i = 0; i < array.length; i++) {
      ret += array[i];
      if (i < array.length-1)
        ret += glue;
    }
    
    return ret;
  }
}
