import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import '../services/api.dart';

class UongThuocScreen extends StatefulWidget {
  final int userId;

  const UongThuocScreen({super.key, required this.userId});

  @override
  _UongThuocScreenState createState() => _UongThuocScreenState();
}

class _UongThuocScreenState extends State<UongThuocScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic>? _uongThuocData;
  bool _isLoading = true;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _fetchUongThuocData();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'medication_reminder_channel',
          'Nhắc nhở uống thuốc',
          channelDescription: 'Thông báo nhắc nhở uống thuốc',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
    );
  }

  Future<void> _fetchUongThuocData() async {
    try {
      final data = await _apiService.layLoiNhacThuoc(widget.userId.toString());
      setState(() {
        _uongThuocData = data;
        _isLoading = false;
      });
      _checkAndNotify();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')));
    }
  }

  void _checkAndNotify() {
    final now = TimeOfDay.now();
    for (var item in _uongThuocData ?? []) {
      final thoiGianNhac = item['thoi_gian_nhac'];
      if (thoiGianNhac != null) {
        final parts = thoiGianNhac.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]);
          final minute = int.tryParse(parts[1]);
          if (hour == now.hour && minute == now.minute) {
            _showNotification(
              'Nhắc nhở uống thuốc',
              'Đã đến giờ uống thuốc: ${item['ten_thuoc'] ?? 'Không có'}',
            );
          }
        }
      }
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, int id, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có chắc muốn xóa lời nhắc này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _apiService.xoaLoiNhacThuoc(id);
                  setState(() {
                    _uongThuocData!.removeAt(index);
                  });
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

  void _showAddMedicineDialog(BuildContext context) {
    final tenThuocController = TextEditingController();
    final lieuLuongController = TextEditingController();
    TimeOfDay? selectedTime;
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Thêm mới thuốc'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tenThuocController,
                  decoration: InputDecoration(labelText: 'Tên thuốc'),
                ),
                TextField(
                  controller: lieuLuongController,
                  decoration: InputDecoration(labelText: 'Liều lượng'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      selectedTime == null
                          ? 'Chọn thời gian'
                          : 'Thời gian: ${selectedTime!.format(context)}',
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            selectedTime = pickedTime;
                          });
                        }
                      },
                      child: Text('Chọn'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      startDate == null
                          ? 'Ngày bắt đầu'
                          : 'Bắt đầu: ${DateFormat('yyyy-MM-dd').format(startDate!)}',
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            startDate = picked;
                          });
                        }
                      },
                      child: Text('Chọn'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      endDate == null
                          ? 'Ngày kết thúc'
                          : 'Kết thúc: ${DateFormat('yyyy-MM-dd').format(endDate!)}',
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            endDate = picked;
                          });
                        }
                      },
                      child: Text('Chọn'),
                    ),
                  ],
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
                if (tenThuocController.text.isNotEmpty &&
                    lieuLuongController.text.isNotEmpty &&
                    selectedTime != null &&
                    startDate != null &&
                    endDate != null) {
                  _addNewMedicine(
                    tenThuocController.text,
                    lieuLuongController.text,
                    selectedTime!,
                    startDate!,
                    endDate!,
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
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

  void _addNewMedicine(
    String tenThuoc,
    String lieuLuong,
    TimeOfDay thoiGian,
    DateTime startDate,
    DateTime endDate,
  ) {
    final formattedTime =
        '${thoiGian.hour.toString().padLeft(2, '0')}:${thoiGian.minute.toString().padLeft(2, '0')}';

    final isDuplicate =
        _uongThuocData?.any(
          (item) =>
              item['ten_thuoc'] == tenThuoc &&
              item['thoi_gian_nhac'] == formattedTime &&
              item['lieu_luong'] == lieuLuong,
        ) ??
        false;

    if (isDuplicate) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lời nhắc đã tồn tại!')));
      return;
    }

    final newMedicine = {
      'maNguoiDung': widget.userId,
      'tenThuoc': tenThuoc,
      'lieuLuong': lieuLuong,
      'thoiGianNhac': formattedTime,
      'ngayBatDau': DateFormat('yyyy-MM-dd').format(startDate),
      'ngayKetThuc': DateFormat('yyyy-MM-dd').format(endDate),
    };

    _apiService
        .themLoiNhacThuoc(newMedicine)
        .then((response) async {
          await _fetchUongThuocData(); // GỌI LẠI API ĐỂ LOAD ĐÚNG DỮ LIỆU
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Thêm thuốc thành công')));
        })
        .catchError((error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi khi thêm thuốc: $error')));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nhắc nhở uống thuốc'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddMedicineDialog(context),
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _uongThuocData == null || _uongThuocData!.isEmpty
              ? Center(child: Text('Không có dữ liệu nhắc nhở uống thuốc'))
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _uongThuocData!.length,
                itemBuilder: (context, index) {
                  final item = _uongThuocData![index];
                  final int? id = item['ma_nhac_nho'];

                  return GestureDetector(
                    onLongPress: () {
                      if (id != null) {
                        _showDeleteConfirmationDialog(context, id, index);
                      }
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tên thuốc: ${item['ten_thuoc'] ?? 'Không có'}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Liều lượng: ${item['lieu_luong'] ?? 'Không có'}',
                            ),
                            Text(
                              'Thời gian nhắc: ${item['thoi_gian_nhac'] ?? 'Không có'}',
                            ),
                            Text(
                              'Ngày bắt đầu: ${item['ngay_bat_dau'] ?? 'Không có'}',
                            ),
                            Text(
                              'Ngày kết thúc: ${item['ngay_ket_thuc'] ?? 'Không có'}',
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
