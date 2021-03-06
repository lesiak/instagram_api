import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:instagram_api/src/constants.dart';
import 'dart:convert';
import 'dart:async';

import 'package:instagram_api/src/io_http_client.dart';

class InstagramScrapper {
  final List<String> _userNames;

  IoHttpClient httpClient = IoHttpClient();

  InstagramScrapper(this._userNames) {}

  Map<String, String> global_headers;

  /**
   *  Authenticate as a guest/non-signed in user
   */
  Future<String> authenticateAsGuest() async {
    //"""Authenticate as a guest/non-signed in user"""
    //self.session.headers.update({'Referer': BASE_URL, 'user-agent': STORIES_UA})
    //req = self.session.get(BASE_URL)

    //self.session.headers.update({'X-CSRFToken': req.cookies['csrftoken']})

    //self.session.headers = {'user-agent': CHROME_WIN_UA}
    //self.rhx_gis = self.get_shared_data()['rhx_gis']
    //self.authenticated = True

   // String csrfToken = await getXsrfToken();

    var headers = {HttpHeaders.userAgentHeader: CHROME_WIN_UA};
    Map<String, dynamic> shared_data = await getSharedData('', headers);
    var rhx_gis = shared_data['rhx_gis'];

    print("rhx_gis: $rhx_gis");
    return rhx_gis;
    //self.authenticated = True
  }

  authenticateWithLogin() async {
    String csrfToken = await getXsrfTokenFromBasePage();
    print(csrfToken);
    var headers = {
      HttpHeaders.refererHeader: BASE_URL,
      HttpHeaders.userAgentHeader: STORIES_UA,
      'X-CSRFToken': csrfToken
    };

  }

  void scrape() async {
    var headers = {HttpHeaders.userAgentHeader: STORIES_UA};
    for (var userName in _userNames) {
      // Get the user metadata.
      Map<String, dynamic> shared_data = await getSharedData(userName, headers);
      Map<String, dynamic> user = getUser(shared_data);
      //print(user);

      if (user == null) {
        print('Error getting user details for $userName. Please verify that the user exists.');
        continue;
      }
      else if (user['is_private'] == true) {
        print('User $userName is private');
        continue;
      }

    }
  }

  dynamic getUser(Map<String, dynamic> shared_data) {
    Map<String, dynamic> user;
    try {
      user = shared_data['entry_data']['ProfilePage'][0]['graphql']['user'];
    } on NoSuchMethodError catch (_) {
      user = null;
    }
    return user;
  }

  Future<String> getXsrfTokenFromBasePage() async {
    var headers = {HttpHeaders.refererHeader: BASE_URL, HttpHeaders.userAgentHeader: STORIES_UA};
    var response = await httpClient.get(BASE_URL, headers: headers);
    var csrfToken = response.getCookie("csrftoken");
    return csrfToken;
  }

  Future<Map<String, dynamic>> getSharedData(String username, Map<String, String> headers) async {
    String resp = await getJson(BASE_URL + username, headers);
    if (resp != null && resp.contains('_sharedData')) {
      final shared_data = resp.split("window._sharedData = ")[1].split(";</script>")[0];
      Map<String, dynamic> parsedJson = json.decode(shared_data);
      return parsedJson;
    } else {
      return {};
    }
  }

  Future<String> getJson(String url, Map<String, String> headers) async {
    var response = await safeGet(url, headers);
    return response?.body;
  }

  Future<IoHttpResponse> safeGet(String url, Map<String, String> headers) {
    return httpClient.get(url, headers: headers).then((resp) {
      if (resp.statusCode == 404) {
        return null;
      }
      return resp;
    });
  }

  void close() {
    httpClient.close();
  }

}
