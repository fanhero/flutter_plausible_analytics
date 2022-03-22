library plausible_analytics;

import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;


import 'dart:developer';


/// Plausible class. Use the constructor to set the parameters.
class Plausible {
  /// The url of your plausible server e.g. https://plausible.io
  String serverUrl;
  String userAgent;
  String domain;
  String screenWidth;
  bool enabled = true;

  /// Constructor
  Plausible(this.serverUrl, this.domain,
      {this.userAgent = "", this.screenWidth = ""});

  /// Post event to plausible
  Future<int> event({String name = "pageview",
    String referrer = "",
    String page = "",
    Map<String, String> props = const {}}) async {
    if (!enabled) {
      return 0;
    }

    // Post-edit parameters
    int lastCharIndex = serverUrl.length - 1;
    if (serverUrl.toString()[lastCharIndex] == '/') {
      // Remove trailing slash '/'
      serverUrl = serverUrl.substring(0, lastCharIndex);
    }
    page = "app://localhost/" + page;
    referrer = "app://localhost/" + referrer;

    // Get and set device infos
    String version = "";

    if (kIsWeb) {
      version = "Windows";
    } else {
      version = Platform.operatingSystemVersion.replaceAll('"', '');
    }

    if (userAgent == "") {
      userAgent = "Mozilla/5.0 ($version; rv:53.0) Gecko/20100101 Chrome/53.0";
    }

    // Http Post request see https://plausible.io/docs/events-api
    try {
      HttpClient client = HttpClient();
      HttpClientRequest request =
      await client.postUrl(Uri.parse(serverUrl + '/api/event'));
      request.headers.set('User-Agent', userAgent);
      request.headers.set('Content-Type', 'application/json; charset=utf-8');
      request.headers.set('X-Forwarded-For', '127.0.0.1');

      props.keys.forEach((element) {
        props[element] = convertToUnicode(value: props[element]);
      });

      Object body = {
        "domain": domain,
        "name": name,
        "url": page,
        "referrer": referrer,
        "screen_width": screenWidth,
        "props": props,
      };

      request.write(json.encode(body).replaceAll("\\\\", "\\"));

      final HttpClientResponse response = await request.close();
      client.close();
      return response.statusCode;
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }

    return 1;
  }

  String convertToUnicode({String value}) {
    var result = "";
    value.runes.forEach((element) {
      var char = element.toRadixString(16);
      if (char.length < 4) {
        result += "\\" + "u00$char";
      } else {
        result += "\\" + "u$char";
      }
    });
    return result;
  }
}
