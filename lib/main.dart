import 'package:digital_camera_photo_geotag_mobile_application/screen_home.dart';
import 'package:flutter/material.dart';
import './screen_connection.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(body: ConnectionScreen()),
        routes: {"/home": (_) => HomeScreen()});
  }
}
