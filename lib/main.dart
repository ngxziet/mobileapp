import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Khu Vực',
      debugShowCheckedModeBanner: false, // tắt banner debug
      theme: ThemeData(
        primarySwatch: Colors.blue,       // màu chủ đạo app
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(),                  // trang đầu tiên là LoginPage
    );
  }
}
