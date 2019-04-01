import 'dart:async';
import 'dart:convert';
import 'dart:io';

class IoHttpClient {
  HttpClient httpClient = HttpClient();

  Future<IoHttpResponse> get(String uri, {Map<String, String> headers}) {
    return getUrl(Uri.parse(uri), headers: headers);
  }

  Future<IoHttpResponse> getUrl(Uri uri, {Map<String, String> headers}) async {
    var request = await httpClient.openUrl('GET', uri);
    headers.forEach((key, value) {
      request.headers.add(key, value);
    });
    //var response = await ;
    return IoHttpResponse(await request.close());
  }

  void close() {
    httpClient.close();
}

}

class IoHttpResponse {
  final HttpClientResponse response;

  IoHttpResponse(this.response);

  Future<String> get body => readResponse();

  Future<String> readResponse() {
    var completer = new Completer<String>();
    var contents = new StringBuffer();
    response.transform(utf8.decoder).listen((String data) {
      contents.write(data);
    }, onDone: () => completer.complete(contents.toString()));
    return completer.future;
  }

  String getCookie(String name) {
    return response.cookies.firstWhere((cookie) => cookie.name == name).value;
  }
}