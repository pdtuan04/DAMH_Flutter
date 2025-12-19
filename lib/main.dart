import 'package:damh_flutter/screens/home.dart';
import 'package:damh_flutter/screens/login_screen.dart';
import 'package:damh_flutter/screens/on_tap_theo_chu_de_screen.dart';
import 'package:damh_flutter/screens/register_screen.dart';
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
      initialRoute: '/login',
      routes: {
        '/home': (context) => Home(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/ontaptheochude': (context) => OnTapTheoChuDeScreen(),
      },
    );
  }
}


