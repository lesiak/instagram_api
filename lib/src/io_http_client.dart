import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/src/utils.dart';

class IoHttpClient {
  final HttpClient httpClient = HttpClient();

  IoHttpClient() {
    httpClient.userAgent = null;
  }

  Future<IoHttpResponse> get(String uri, {Map<String, String> headers}) {
    return getUrl(Uri.parse(uri), headers: headers);
  }

  Future<IoHttpResponse> getUrl(Uri uri, {Map<String, String> headers}) async {
    var request = await httpClient.openUrl('GET', uri);
    headers.forEach((key, value) {
      request.headers.add(key, value);
    });
    return IoHttpResponse(await request.close());
  }

  Future<IoHttpResponse> postFormData(Uri uri, Map<String, String> data) async {
    var request = await httpClient.postUrl(uri);
    var encoding = utf8;
    var body = mapToQuery(data, encoding: encoding);
    request.headers.add('content-type', 'application/x-www-form-urlencoded; charset=utf-8');
    request.contentLength = body.length;
    request.write(body);
    return IoHttpResponse(await request.close());
  }

  set findProxy(String f(Uri url)) => httpClient.findProxy = f;

  void close() {
    httpClient.close();
  }

}

class IoHttpResponse {
  final HttpClientResponse response;

  IoHttpResponse(this.response);

  Future<String> get body => _readResponse();

  List<Cookie> get cookies => response.cookies;

  int get statusCode => response.statusCode;

  String getCookie(String name) {
    return response.cookies.firstWhere((cookie) => cookie.name == name).value;
  }

  Future<String> _readResponse() {
    var completer = new Completer<String>();
    var contents = new StringBuffer();
    response.transform(utf8.decoder).listen((String data) {
      contents.write(data);
    }, onDone: () => completer.complete(contents.toString()));
    return completer.future;
  }

}
