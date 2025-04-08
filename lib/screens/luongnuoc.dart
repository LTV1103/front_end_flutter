import 'package:flutter/material.dart';
import '../services/api.dart';

class LuongNuocScreen extends StatefulWidget {
  final int userId; // Nhận ID người dùng từ màn hình trước

  const LuongNuocScreen({super.key, required this.userId});

  @override
  _LuongNuocScreenState createState() => _LuongNuocScreenState();
}

class _LuongNuocScreenState extends State<LuongNuocScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic>? _luongNuocData; // Dữ liệu danh sách lượng nước
  bool _isLoading = true; // Trạng thái tải dữ liệu

  @override
  void initState() {
    super.initState();
    _fetchLuongNuocData(); // Gọi API khi màn hình được khởi tạo
  }

  Future<void> _fetchLuongNuocData() async {
    try {
      final data = await _apiService.layDanhSachLuongNuoc(
        widget.userId.toString(),
      );
      setState(() {
        _luongNuocData = data; // Gán dữ liệu lượng nước vào _luongNuocData
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lượng nước uống')),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(),
              ) // Hiển thị vòng tròn tải
              : _luongNuocData == null || _luongNuocData!.isEmpty
              ? Center(child: Text('Không có dữ liệu lượng nước'))
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _luongNuocData!.length,
                itemBuilder: (context, index) {
                  final item = _luongNuocData![index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thời gian: ${item['thoi_gian'] ?? 'Không có'}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Lượng nước: ${item['luong_nuoc'] ?? 'Không có'} ml',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Ghi chú: ${item['ghi_chu'] ?? 'Không có'}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

