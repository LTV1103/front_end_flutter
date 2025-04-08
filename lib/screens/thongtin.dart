import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thư viện để định dạng ngày tháng
import '../services/api.dart';

class ThongTinScreen extends StatefulWidget {
  final int userId;

  const ThongTinScreen({super.key, required this.userId});

  @override
  _ThongTinScreenState createState() => _ThongTinScreenState();
}

class _ThongTinScreenState extends State<ThongTinScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData; // Dữ liệu thông tin người dùng
  bool _isLoading = true;
  bool _isEditing = false; // Trạng thái chỉnh sửa
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate; // Ngày sinh được chọn

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Gọi API khi màn hình được khởi tạo
  }

  Future<void> _fetchUserData() async {
    try {
      final data = await _apiService.layNguoiDungTheoId(widget.userId);
      setState(() {
        _userData = data.isNotEmpty ? data[0] : null; // Lấy thông tin đầu tiên
        if (_userData != null && _userData!['ngay_sinh'] != null) {
          _selectedDate = DateFormat(
            'yyyy-MM-dd',
          ).parse(_userData!['ngay_sinh']);
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')));
    }
  }

  Future<void> _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        if (_selectedDate != null) {
          _userData!['ngay_sinh'] = DateFormat(
            'yyyy-MM-dd',
          ).format(_selectedDate!);
        }
        await _apiService.capNhatNguoiDung(widget.userId, _userData!);
        setState(() {
          _isEditing = false; // Thoát chế độ chỉnh sửa
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật thông tin thành công!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi cập nhật thông tin: $e')),
        );
      }
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _userData == null
              ? Center(child: Text('Không có dữ liệu'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // Hiển thị thông tin người dùng
                      TextFormField(
                        initialValue: _userData!['ho_ten'],
                        enabled: _isEditing,
                        decoration: InputDecoration(
                          labelText: 'Họ và tên',
                          prefixIcon: Icon(Icons.person, color: Colors.blue),
                        ),
                        onSaved: (value) {
                          _userData!['ho_ten'] = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Họ và tên không được để trống';
                          }
                          return null;
                        },
                      ),
                      Divider(),
                      TextFormField(
                        initialValue: _userData!['so_dien_thoai'],
                        enabled: _isEditing,
                        decoration: InputDecoration(
                          labelText: 'Số điện thoại',
                          prefixIcon: Icon(Icons.phone, color: Colors.orange),
                        ),
                        onSaved: (value) {
                          _userData!['so_dien_thoai'] = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Số điện thoại không được để trống';
                          }
                          return null;
                        },
                      ),
                      Divider(),
                      // Ngày sinh
                      GestureDetector(
                        onTap:
                            _isEditing
                                ? () {
                                  _selectDate(context);
                                }
                                : null,
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: TextEditingController(
                              text:
                                  _selectedDate != null
                                      ? DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(_selectedDate!)
                                      : '',
                            ),
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: 'Ngày sinh',
                              prefixIcon: Icon(
                                Icons.cake,
                                color: Colors.purple,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Divider(),
                      // Giới tính
                      if (_isEditing)
                        DropdownButtonFormField<String>(
                          value: _userData!['gioi_tinh'],
                          items:
                              ['Nam', 'Nữ', 'Bí mật']
                                  .map(
                                    (gender) => DropdownMenuItem(
                                      value: gender,
                                      child: Text(gender),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              _userData!['gioi_tinh'] = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Giới tính',
                            prefixIcon: Icon(Icons.male, color: Colors.indigo),
                          ),
                        )
                      else
                        TextFormField(
                          initialValue: _userData!['gioi_tinh'],
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: 'Giới tính',
                            prefixIcon: Icon(Icons.male, color: Colors.indigo),
                          ),
                        ),
                      Divider(),
                      SizedBox(height: 20),
                      // Nút Sửa hoặc Lưu
                      ElevatedButton(
                        onPressed: () {
                          if (_isEditing) {
                            _saveUserData();
                          } else {
                            setState(() {
                              _isEditing = true; // Bật chế độ chỉnh sửa
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isEditing ? Colors.green : Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Text(
                          _isEditing ? 'Lưu' : 'Sửa thông tin',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Nút Đăng xuất
                      ElevatedButton(
                        onPressed: () {
                          _showLogoutDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Text(
                          'Đăng xuất',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  // Hàm hiển thị Dialog xác nhận đăng xuất
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận'),
          content: Text('Bạn có chắc chắn muốn đăng xuất không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                _logout(); // Gọi hàm đăng xuất
              },
              child: Text('Đăng xuất'),
            ),
          ],
        );
      },
    );
  }

  // Hàm xử lý đăng xuất
  void _logout() {
    Navigator.pushReplacementNamed(
      context,
      '/login',
    ); // Điều hướng về màn hình đăng nhập
  }
}
