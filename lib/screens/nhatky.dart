import 'package:flutter/material.dart';
import '../services/api.dart';

class NhatKyScreen extends StatefulWidget {
  final int userId; // Nhận ID người dùng từ màn hình trước

  const NhatKyScreen({super.key, required this.userId});

  @override
  _NhatKyScreenState createState() => _NhatKyScreenState();
}

class _NhatKyScreenState extends State<NhatKyScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic>? _nhatKyData; // Dữ liệu danh sách nhật ký
  bool _isLoading = true; // Trạng thái tải dữ liệu

  @override
  void initState() {
    super.initState();
    _fetchNhatKyData(); // Gọi API khi màn hình được khởi tạo
  }

  Future<void> _fetchNhatKyData() async {
    try {
      final data = await _apiService.layNhatKy(widget.userId);
      setState(() {
        _nhatKyData = data; // Gán dữ liệu nhật ký vào _nhatKyData
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
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(),
              ) // Hiển thị vòng tròn tải
              : _nhatKyData == null || _nhatKyData!.isEmpty
              ? Center(child: Text('Không có dữ liệu nhật ký'))
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _nhatKyData!.length,
                itemBuilder: (context, index) {
                  final item = _nhatKyData![index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loại hoạt động: ${item['loai_hoat_dong'] ?? 'Không có'}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Thời gian: ${item['thoi_gian_phut'] ?? 'Không có'} phút',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Calo tiêu hao: ${item['calo_tieu_hao'] ?? 'Không có'} kcal',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Ngày hoạt động: ${item['ngay_hoat_dong'] ?? 'Không có'}',
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
