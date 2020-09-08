import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class Resource<T> {
  final String url;
  T Function(Response response) parse;

  Resource({this.url, this.parse});
}

class WebService {
  Future<T> load<T>(Resource<T> resource) async {
    final response = await http.get(resource.url);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      return resource.parse(response);
    } else {
      // If the server did not return a 200 OK response, then throw an exception.
      throw Exception('Failed to load data');
    }
  }

  static Future<Response> postRoute(
      String routeData, double distance, int duration) async {
    String url;
    // if (Platform.isAndroid) {
    //   url = LocalHost.urlAndroid + 'routes/create';
    // } else if (Platform.isIOS) {
    //   url = LocalHost.urlIos + 'routes/create';
    // }
    url = "https://jnz5ygxmkf.execute-api.us-east-1.amazonaws.com/api/v1/routes/create";
    final http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'route_data': routeData,
        'distance': distance,
        'duration': duration,
      }),
    );
    return response;
  }
}
