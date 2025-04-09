import 'package:flutter/material.dart';
import '../services/api.dart';
import 'hoatdong.dart';
import 'package:intl/intl.dart';
import '../models/nhatky_model.dart'; // Thêm thư viện intl

class NhatKyScreen extends StatefulWidget {
  final int userId; // Nhận ID người dùng từ màn hình trước

  const NhatKyScreen({super.key, required this.userId});

  @override
  _NhatKyScreenState createState() => _NhatKyScreenState();
}

class _NhatKyScreenState extends State<NhatKyScreen> {
  final ApiService _apiService = ApiService();
  List<NhatKy>? _nhatKyData; // Dữ liệu danh sách nhật ký
  bool _isLoading = true; // Trạng thái tải dữ liệu

  // Map ánh xạ loại hoạt động với icon
  final Map<String, IconData> _activityIcons = {
    'Chạy bộ': Icons.directions_run,
    'Đạp xe': Icons.directions_bike,
    'Gym': Icons.fitness_center,
    'Nhảy Dây': Icons.sports_kabaddi,
    'Bơi': Icons.pool,
  };

  @override
  void initState() {
    super.initState();
    _fetchNhatKyData(); // Gọi API khi màn hình được khởi tạo
  }

  Future<void> _fetchNhatKyData() async {
    try {
      final data = await _apiService.layNhatKy(widget.userId);
      setState(() {
        _nhatKyData =
            data.map<NhatKy>((item) => NhatKy.fromJson(item)).toList();
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
              ? Center(child: CircularProgressIndicator())
              : _nhatKyData == null || _nhatKyData!.isEmpty
              ? Center(child: Text('Không có dữ liệu nhật ký'))
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _nhatKyData!.length,
                itemBuilder: (context, index) {
                  final item = _nhatKyData![index];
                  final icon =
                      _activityIcons[item.loaiHoatDong] ?? Icons.help_outline;

                  return GestureDetector(
                    onLongPress: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: Text('Xóa hoạt động'),
                              content: Text(
                                'Bạn có chắc muốn xóa hoạt động này không?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text('Xóa'),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        try {
                          await _apiService.xoaNhatKy(item.maHoatDong);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Xóa thành công')),
                          );
                          _fetchNhatKyData(); // Reload dữ liệu sau khi xóa
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi khi xóa: $e')),
                          );
                        }
                      }
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(icon, size: 40, color: Colors.blueAccent),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Loại hoạt động: ${item.loaiHoatDong}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Thời gian: ${item.thoiGianPhut} phút',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Calo tiêu hao: ${item.caloTieuHao} kcal',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Ngày hoạt động: ${DateFormat('dd/MM/yyyy').format(item.ngayHoatDong)}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ThemHoatDongScreen(
                                          userId: widget.userId,
                                          hoatDong:
                                              item, // Truyền dữ liệu hoạt động để sửa
                                        ),
                                  ),
                                );
                                if (result == true) {
                                  _fetchNhatKyData(); // Reload dữ liệu sau khi sửa thành công
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThemHoatDongScreen(userId: widget.userId),
            ),
          );
          if (result == true) {
            _fetchNhatKyData(); // Reload dữ liệu sau khi thêm thành công
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
