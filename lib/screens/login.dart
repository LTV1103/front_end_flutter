import 'package:flutter/material.dart';
import '../services/api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final api = ApiService(); // Khởi tạo ApiService

  // Hàm đăng nhập
  Future<void> _login(BuildContext context) async {
    String username = _emailController.text;
    String password = _passwordController.text;

    // Kiểm tra dữ liệu đầu vào
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập tên đăng nhập và mật khẩu')),
      );
      return;
    }

    // Tạo đối tượng data để gửi đến API
    Map<String, dynamic> data = {'email': username, 'mat_khau': password};

    try {
      // Gửi yêu cầu đăng nhập qua ApiService
      var response = await api.dangNhapNguoiDung(data);

      // Xử lý phản hồi từ API
      if (response['status'] == 'success') {
        // Đăng nhập thành công, chuyển hướng đến màn hình chính
        Navigator.pushNamed(
          context,
          '/home',
          arguments: response['data']['id'], // Truyền userId đến HomeScreen
        );
      } else {
        // Hiển thị thông báo lỗi nếu đăng nhập thất bại
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Đăng nhập thất bại')),
        );
      }
    } catch (e) {
      // Xử lý lỗi kết nối hoặc lỗi khác
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi kết nối: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng Nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('Đăng Nhập'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Chưa có tài khoản?'),
                TextButton(
                  onPressed: () {
                    // Điều hướng đến trang đăng ký
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text('Đăng ký ngay'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
