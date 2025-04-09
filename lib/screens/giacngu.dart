import 'package:flutter/material.dart';
import '../services/api.dart';
import 'package:intl/intl.dart';
import '../models/giacngu_model.dart';

class GhiChepScreen extends StatefulWidget {
  final int userId;

  const GhiChepScreen({super.key, required this.userId});

  @override
  _GhiChepScreenState createState() => _GhiChepScreenState();
}

class _GhiChepScreenState extends State<GhiChepScreen> {
  final ApiService _apiService = ApiService();
  List<GiacNgu>? _ghiChepData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGhiChepData();
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

  Future<void> _addGhiChep(DateTime batDau, DateTime ketThuc) async {
    try {
      final response = await _apiService.themGhiChep({
        'ma_nguoi_dung': widget.userId,
        'thoi_gian_bat_dau': batDau.toIso8601String(),
        'thoi_gian_ket_thuc': ketThuc.toIso8601String(),
      });

      if (response['status'] == 'success') {
        await _fetchGhiChepData(); // Tải lại danh sách sau khi thêm thành công
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Thêm ghi chép thành công')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${response['message']}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi thêm ghi chép: $e')));
    }
  }

  Future<void> _deleteGhiChep(int id) async {
    try {
      await _apiService.xoaGhiChep(id);
      await _fetchGhiChepData();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Xóa ghi chép thành công')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa ghi chép: $e')));
    }
  }

  void _showAddDialog() {
    DateTime? batDau;
    DateTime? ketThuc;
    String? chatLuong;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Thêm ghi chép giấc ngủ'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () async {
                        final picked = await showDateTimePicker(context);
                        if (picked != null) {
                          setState(() {
                            batDau = picked;
                          });
                        }
                      },
                      child: Text('Chọn thời gian bắt đầu'),
                    ),
                    if (batDau != null)
                      Text(
                        'Thời gian bắt đầu: ${DateFormat('yyyy-MM-dd HH:mm').format(batDau!)}',
                        style: TextStyle(fontSize: 16),
                      ),
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDateTimePicker(context);
                        if (picked != null) {
                          setState(() {
                            ketThuc = picked;
                            if (batDau != null) {
                              final duration =
                                  ketThuc!.difference(batDau!).inHours;
                              if (duration < 6 || duration > 9) {
                                chatLuong = 'Kém';
                              } else if (duration >= 6 && duration <= 9) {
                                chatLuong = 'Tốt';
                              } else {
                                chatLuong = 'Trung bình';
                              }
                            }
                          });
                        }
                      },
                      child: Text('Chọn thời gian kết thúc'),
                    ),
                    if (ketThuc != null)
                      Text(
                        'Thời gian kết thúc: ${DateFormat('yyyy-MM-dd HH:mm').format(ketThuc!)}',
                        style: TextStyle(fontSize: 16),
                      ),
                    SizedBox(height: 8),
                    if (chatLuong != null)
                      Text(
                        'Chất lượng giấc ngủ: $chatLuong',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Hủy'),
                ),
                TextButton(
                  onPressed: () {
                    if (batDau != null && ketThuc != null) {
                      _addGhiChep(batDau!, ketThuc!);
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Vui lòng chọn thời gian hợp lệ'),
                        ),
                      );
                    }
                  },
                  child: Text('Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<DateTime?> showDateTimePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _showDeleteConfirmationDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có chắc muốn xóa ghi chép này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Đóng hộp thoại
                try {
                  await _deleteGhiChep(id); // Gọi hàm xóa
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Xóa thành công')));
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa: $e')));
                }
              },
              child: Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ghi chép giấc ngủ'),
        actions: [IconButton(icon: Icon(Icons.add), onPressed: _showAddDialog)],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _ghiChepData == null || _ghiChepData!.isEmpty
              ? Center(child: Text('Không có dữ liệu ghi chép'))
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _ghiChepData!.length,
                itemBuilder: (context, index) {
                  final item = _ghiChepData![index];
                  return GestureDetector(
                    onLongPress: () {
                      _showDeleteConfirmationDialog(context, item.maGhiChep);
                    },
                    child: Card(
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
                    ),
                  );
                },
              ),
    );
  }
}
