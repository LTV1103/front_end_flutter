import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api.dart';

class ThemHoatDongScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic>? hoatDong;

  const ThemHoatDongScreen({super.key, required this.userId, this.hoatDong});

  @override
  _ThemHoatDongScreenState createState() => _ThemHoatDongScreenState();
}

class _ThemHoatDongScreenState extends State<ThemHoatDongScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  late String? _loaiHoatDong;
  late TextEditingController _ngayController;
  late TextEditingController _thoiGianController;

  final Map<String, double> _metValues = {
    'Chạy bộ': 9.8,
    'Đạp xe': 7.5,
    'Gym': 6.0,
    'Nhảy Dây': 12.0,
    'Bơi': 8.0,
  };

  @override
  void initState() {
    super.initState();
    _loaiHoatDong = widget.hoatDong?['loai_hoat_dong'];
    _ngayController = TextEditingController(
      text: widget.hoatDong?['ngay_hoat_dong'] ?? '',
    );
    _thoiGianController = TextEditingController(
      text: widget.hoatDong?['thoi_gian_phut']?.toString() ?? '',
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (widget.hoatDong == null) {
        // Dữ liệu cho thêm mới
        final data = {
          'loai_hoat_dong': _loaiHoatDong,
          'ngay_hoat_dong': _ngayController.text,
          'thoi_gian_phut': int.parse(_thoiGianController.text),
        };
        // Gọi API thêm mới
        final response = await _apiService.themHoatDongNhatKy(
          widget.userId.toString(),
          data,
        );
        _handleResponse(response, isUpdate: false);
      } else {
        // Dữ liệu cho cập nhật
        final updatedData = {
          'loai_hoat_dong': _loaiHoatDong,
          'ngay_hoat_dong':
              '${_ngayController.text} 00:00:00', // Định dạng ngày
          'thoi_gian_phut': int.parse(_thoiGianController.text),
          'ma_nguoi_dung': widget.userId,
        };

        // Gọi API cập nhật
        final response = await _apiService.capNhatNhatKy(
          updatedData,
          widget.hoatDong!['ma_hoat_dong'],
        );
        _handleResponse(response, isUpdate: true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi xử lý: $e')));
    }
  }

  void _handleResponse(
    Map<String, dynamic> response, {
    required bool isUpdate,
  }) {
    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isUpdate ? 'Cập nhật thành công' : 'Thêm hoạt động thành công',
          ),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${response['message']}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.hoatDong == null ? 'Thêm Hoạt Động' : 'Sửa Hoạt Động',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _loaiHoatDong,
                items:
                    _metValues.keys.map((hoatDong) {
                      return DropdownMenuItem(
                        value: hoatDong,
                        child: Text(hoatDong),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _loaiHoatDong = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Loại hoạt động'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn loại hoạt động';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ngayController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Ngày hoạt động (YYYY-MM-DD)',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate:
                            _ngayController.text.isNotEmpty
                                ? DateTime.parse(_ngayController.text)
                                : DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _ngayController.text = DateFormat(
                            'yyyy-MM-dd',
                          ).format(pickedDate);
                        });
                      }
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn ngày hoạt động';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _thoiGianController,
                decoration: InputDecoration(labelText: 'Thời gian (phút)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập thời gian';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Thời gian không hợp lệ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(widget.hoatDong == null ? 'Thêm' : 'Cập nhật'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
