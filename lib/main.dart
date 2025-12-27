import 'package:damh_flutter/screens/home.dart';
import 'package:damh_flutter/screens/login_screen.dart';
import 'package:damh_flutter/screens/on_tap_theo_chu_de_screen.dart';
import 'package:damh_flutter/screens/register_screen.dart';
import 'package:damh_flutter/screens/admin/admin_home_screen.dart';
import 'package:damh_flutter/screens/admin/loaibanglai/quanly_loai_bang_lai.dart';
import 'package:damh_flutter/screens/admin/chude/quanly_chu_de.dart';
import 'package:damh_flutter/screens/admin/cauhoi/quanly_cau_hoi.dart';
import 'package:damh_flutter/screens/admin/baithi/quanly_bai_thi.dart';
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
        '/admin': (context) => AdminHomeScreen(),
        '/admin/loai-bang-lai': (context) => QuanLyLoaiBangLai(),
        '/admin/chu-de': (context) => QuanLyChuDe(),
        '/admin/cau-hoi': (context) => QuanLyCauHoi(),
        '/admin/bai-thi': (context) => QuanLyBaiThi(),
      },
    );
  }
}


