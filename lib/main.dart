import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'Main_Screen.dart';
import 'Table_Screen.dart';
import 'Report_Screen.dart';
import 'Login_Screen.dart';
void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

  runApp(Caffe());}

class Caffe extends StatefulWidget {
  @override
  _CaffeState createState() => _CaffeState();
}

class _CaffeState extends State<Caffe> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: LoginScreen.id,
      routes: {
        MainScreen.id : (context) => MainScreen(),
        TableScreen.id:(context) =>TableScreen(),
        ReportScreen.id:(context) =>ReportScreen(),
        LoginScreen.id:(context) =>LoginScreen(),

      },
    );
  }
}
