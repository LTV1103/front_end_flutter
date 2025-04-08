import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Logo nằm ở giữa
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/logo1.png', // Đảm bảo logo được đặt trong thư mục assets
                width: 350,
                height: 300,
              ),
            ),
          ),
          // Nút Login nằm dưới
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton(
              onPressed: () {
                // Điều hướng đến màn hình đăng nhập
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(
                  255,
                  102,
                  102,
                  166,
                ), // Màu tím xanh đặc trưng
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(vertical: 15),
                minimumSize: Size(double.infinity, 50), // Nút dài hơn
              ),
              child: Text(
                'Login',
                style: TextStyle(
                  fontSize: 18,
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
          ),
          SizedBox(height: 30), // Khoảng cách từ nút đến đáy màn hình
        ],
      ),
    );
  }
}
