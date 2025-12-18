import 'package:damh_flutter/screens/home.dart';
import 'package:damh_flutter/screens/login_screen.dart';
import 'package:flutter/material.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/home': (context) => Home(),
        '/': (context) => LoginScreen(),
      },
    );
  }
}


