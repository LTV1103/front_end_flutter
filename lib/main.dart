import 'package:flutter/material.dart';
import 'package:front_end_flutter/screens/chiso.dart';
import 'package:front_end_flutter/screens/giacngu.dart';
import 'package:front_end_flutter/screens/luongnuoc.dart';
import 'package:front_end_flutter/screens/nhatky.dart';
import 'package:front_end_flutter/screens/thongtin.dart';
import 'package:front_end_flutter/screens/welcome.dart';
import 'package:front_end_flutter/screens/uongthuoc.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ứng dụng Flutter',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/welcome', // Đặt màn hình khởi động là LoginScreen
      routes: {
        '/welcome': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
      },
      // Sử dụng onGenerateRoute để xử lý các route động
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final int userId =
              settings.arguments as int; // Lấy userId từ arguments
          return MaterialPageRoute(
            builder: (context) => HomeScreen(userId: userId),
          );
        } else if (settings.name == '/chiso') {
          final int userId =
              settings.arguments as int; // Lấy userId từ arguments
          return MaterialPageRoute(
            builder: (context) => ChiSoScreen(userId: userId),
          );
        } else if (settings.name == '/nhatky') {
          final int userId =
              settings.arguments as int; // Lấy userId từ arguments
          return MaterialPageRoute(
            builder: (context) => NhatKyScreen(userId: userId),
          );
        } else if (settings.name == '/luongnuoc') {
          final int userId =
              settings.arguments as int; // Lấy userId từ arguments
          return MaterialPageRoute(
            builder: (context) => LuongNuocScreen(userId: userId),
          );
        } else if (settings.name == '/ghichep') {
          final int userId =
              settings.arguments as int; // Lấy userId từ arguments
          return MaterialPageRoute(
            builder: (context) => GhiChepScreen(userId: userId),
          );
        } else if (settings.name == '/uongthuoc') {
          final int userId =
              settings.arguments as int; // Lấy userId từ arguments
          return MaterialPageRoute(
            builder: (context) => UongThuocScreen(userId: userId),
          );
        }
        else if (settings.name == '/nguoidung') {
          final int userId =
              settings.arguments as int; // Lấy userId từ arguments
          return MaterialPageRoute(
            builder: (context) => ThongTinScreen(userId: userId),
          );
        } 
        return null; // Trả về null nếu route không được định nghĩa
      },
    );
  }
}
