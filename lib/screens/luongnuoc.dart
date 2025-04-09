import 'package:flutter/material.dart';
import '../services/api.dart';
import '../models/luongnuoc_model.dart';
import 'package:intl/intl.dart';

class LuongNuocScreen extends StatefulWidget {
  final int userId;

  const LuongNuocScreen({super.key, required this.userId});

  @override
  _LuongNuocScreenState createState() => _LuongNuocScreenState();
}

class _LuongNuocScreenState extends State<LuongNuocScreen> {
  final ApiService _apiService = ApiService();
  List<LuongNuoc>? _luongNuocData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLuongNuocData();
  }

  Future<void> _fetchLuongNuocData() async {
    try {
      final data = await _apiService.layDanhSachLuongNuoc(
        widget.userId.toString(),
      );
      setState(() {
        _luongNuocData =
            data.map<LuongNuoc>((item) => LuongNuoc.fromJson(item)).toList();
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

  Future<void> _addLuongNuoc(int luongMl) async {
    try {
      final now = DateTime.now();
      final newLuongNuoc = LuongNuoc(
        maLuongNuoc: 0,
        maNguoiDung: widget.userId,
        luongMl: luongMl,
        thoiGianGhi: now,
      );

      await _apiService.themLuongNuoc(newLuongNuoc.toJson());
      await _fetchLuongNuocData();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Thêm lượng nước thành công')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi thêm lượng nước: $e')));
    }
  }

  Future<void> _deleteLuongNuoc(int id) async {
    try {
      await _apiService.xoaLuongNuoc(id);
      await _fetchLuongNuocData();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Xóa lượng nước thành công')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa lượng nước: $e')));
    }
  }

  Future<void> _editLuongNuoc(LuongNuoc luongNuoc, int luongMl) async {
    try {
      final updatedLuongNuoc = LuongNuoc(
        maLuongNuoc: luongNuoc.maLuongNuoc,
        maNguoiDung: widget.userId,
        luongMl: luongMl,
        thoiGianGhi: luongNuoc.thoiGianGhi,
      );

      await _apiService.capNhatLuongNuoc(
        updatedLuongNuoc.toJson(),
        luongNuoc.maLuongNuoc,
      );
      await _fetchLuongNuocData();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cập nhật lượng nước thành công')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật lượng nước: $e')),
      );
    }
  }

  int _tinhTongLuongNuocTrongNgay() {
    final today = DateTime.now();
    return _luongNuocData
            ?.where(
              (item) =>
                  item.thoiGianGhi.year == today.year &&
                  item.thoiGianGhi.month == today.month &&
                  item.thoiGianGhi.day == today.day,
            )
            .fold(0, (sum, item) => sum! + item.luongMl) ??
        0;
  }

  void _showAddDialog() {
    final TextEditingController luongNuocController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Thêm lượng nước'),
          content: TextField(
            controller: luongNuocController,
            decoration: InputDecoration(labelText: 'Nhập lượng nước (ml)'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                final luongMl = int.tryParse(luongNuocController.text);
                if (luongMl != null && luongMl > 0) {
                  _addLuongNuoc(luongMl);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vui lòng nhập số hợp lệ')),
                  );
                }
              },
              child: Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(LuongNuoc luongNuoc) {
    final TextEditingController editController = TextEditingController(
      text: luongNuoc.luongMl.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sửa lượng nước'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(labelText: 'Nhập lượng nước (ml)'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                final newLuongMl = int.tryParse(editController.text);
                if (newLuongMl != null && newLuongMl > 0) {
                  await _editLuongNuoc(luongNuoc, newLuongMl);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vui lòng nhập số hợp lệ')),
                  );
                }
              },
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có chắc muốn xóa lượng nước này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _deleteLuongNuoc(id);
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
        title: Text('Lượng nước uống'),
        actions: [IconButton(icon: Icon(Icons.add), onPressed: _showAddDialog)],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _luongNuocData == null || _luongNuocData!.isEmpty
              ? Center(child: Text('Không có dữ liệu lượng nước'))
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Tổng lượng nước hôm nay: ${_tinhTongLuongNuocTrongNgay()} ml',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _luongNuocData!.length,
                      itemBuilder: (context, index) {
                        final item = _luongNuocData![index];
                        return GestureDetector(
                          onLongPress: () {
                            _showDeleteConfirmationDialog(
                              context,
                              item.maLuongNuoc,
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Thời gian: ${DateFormat('yyyy-MM-dd HH:mm').format(item.thoiGianGhi)}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Lượng nước: ${item.luongMl} ml',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          _showEditDialog(item);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
