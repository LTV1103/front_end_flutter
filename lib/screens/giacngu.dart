import 'package:flutter/material.dart';
import '../services/api.dart';
import 'package:intl/intl.dart';
import '../models/giacngu_model.dart';

class GhiChepScreen extends StatefulWidget {
  final int userId; // Nhận ID người dùng từ màn hình trước

  const GhiChepScreen({super.key, required this.userId});

  @override
  _GhiChepScreenState createState() => _GhiChepScreenState();
}

class _GhiChepScreenState extends State<GhiChepScreen> {
  final ApiService _apiService = ApiService();
  List<GiacNgu>? _ghiChepData; // Dữ liệu danh sách ghi chép
  bool _isLoading = true; // Trạng thái tải dữ liệu

  @override
  void initState() {
    super.initState();
    _fetchGhiChepData(); // Gọi API khi màn hình được khởi tạo
  }

  Future<void> _fetchGhiChepData() async {
    try {
      final data = await _apiService.layGhiChep(widget.userId.toString());
      setState(() {
        _ghiChepData =
            data.map<GiacNgu>((item) => GiacNgu.fromJson(item)).toList();
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
      appBar: AppBar(title: Text('Ghi chép giấc ngủ')),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(),
              ) // Hiển thị vòng tròn tải
              : _ghiChepData == null || _ghiChepData!.isEmpty
              ? Center(child: Text('Không có dữ liệu ghi chép'))
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _ghiChepData!.length,
                itemBuilder: (context, index) {
                  final item = _ghiChepData![index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thời gian bắt đầu: ${DateFormat('yyyy-MM-dd HH:mm').format(item.thoiGianBatDau)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Thời gian kết thúc: ${DateFormat('yyyy-MM-dd HH:mm').format(item.thoiGianKetThuc)}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Chất lượng giấc ngủ: ${item.chatLuongGiacNgu ?? 'Không có'}',
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
