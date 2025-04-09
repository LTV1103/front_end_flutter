import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import '../services/api.dart';
import '../models/uongthuoc_model.dart';

class UongThuocScreen extends StatefulWidget {
  final int userId;

  const UongThuocScreen({super.key, required this.userId});

  @override
  _UongThuocScreenState createState() => _UongThuocScreenState();
}

class _UongThuocScreenState extends State<UongThuocScreen> {
  final ApiService _apiService = ApiService();
  List<UongThuoc>? _uongThuocData;
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
        _uongThuocData =
            data.map<UongThuoc>((item) => UongThuoc.fromJson(item)).toList();
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
      final parts = item.thoiGianNhac.split(':');
      if (parts.length == 3) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour == now.hour && minute == now.minute) {
          _showNotification(
            'Nhắc nhở uống thuốc',
            'Đã đến giờ uống thuốc: ${item.tenThuoc}',
          );
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
                  await _fetchUongThuocData(); // Reload danh sách sau khi xóa thành công
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

  void _addNewMedicine(
    String tenThuoc,
    String lieuLuong,
    TimeOfDay thoiGian,
    DateTime startDate,
    DateTime endDate,
  ) {
    final formattedTime =
        '${thoiGian.hour.toString().padLeft(2, '0')}:${thoiGian.minute.toString().padLeft(2, '0')}:00';

    final newMedicine = UongThuoc(
      maNhacNho: 0, // Không cần gửi trường này lên API
      maNguoiDung: widget.userId,
      tenThuoc: tenThuoc,
      lieuLuong: lieuLuong,
      thoiGianNhac: formattedTime,
      ngayBatDau: startDate,
      ngayKetThuc: endDate,
    );

    print(
      'Dữ liệu gửi lên API: ${newMedicine.toJson(includeId: false)}',
    ); // Kiểm tra dữ liệu JSON

    _apiService
        .themLoiNhacThuoc(newMedicine.toJson(includeId: false))
        .then((response) async {
          await _fetchUongThuocData(); // Reload danh sách sau khi thêm thành công
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

  void _showAddMedicineDialog(BuildContext context) {
    final TextEditingController tenThuocController = TextEditingController();
    final TextEditingController lieuLuongController = TextEditingController();
    TimeOfDay? selectedTime;
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Thêm thuốc mới'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      selectedTime = pickedTime;
                    }
                  },
                  child: Text('Chọn thời gian nhắc'),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      startDate = pickedDate;
                    }
                  },
                  child: Text('Chọn ngày bắt đầu'),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      endDate = pickedDate;
                    }
                  },
                  child: Text('Chọn ngày kết thúc'),
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
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _editMedicine(UongThuoc medicine, int index) {
    final TextEditingController tenThuocController = TextEditingController(
      text: medicine.tenThuoc,
    );
    final TextEditingController lieuLuongController = TextEditingController(
      text: medicine.lieuLuong,
    );
    TimeOfDay? selectedTime = TimeOfDay(
      hour: int.parse(medicine.thoiGianNhac.split(':')[0]),
      minute: int.parse(medicine.thoiGianNhac.split(':')[1]),
    );
    DateTime? startDate = medicine.ngayBatDau;
    DateTime? endDate = medicine.ngayKetThuc;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sửa thông tin thuốc'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      selectedTime = pickedTime;
                    }
                  },
                  child: Text('Chọn thời gian nhắc'),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      startDate = pickedDate;
                    }
                  },
                  child: Text('Chọn ngày bắt đầu'),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      endDate = pickedDate;
                    }
                  },
                  child: Text('Chọn ngày kết thúc'),
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
              onPressed: () async {
                // Sử dụng giá trị hiện tại nếu người dùng không thay đổi
                final updatedMedicine = UongThuoc(
                  maNhacNho: medicine.maNhacNho,
                  maNguoiDung: widget.userId,
                  tenThuoc:
                      tenThuocController.text.isNotEmpty
                          ? tenThuocController.text
                          : medicine.tenThuoc,
                  lieuLuong:
                      lieuLuongController.text.isNotEmpty
                          ? lieuLuongController.text
                          : medicine.lieuLuong,
                  thoiGianNhac:
                      selectedTime != null
                          ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00'
                          : medicine.thoiGianNhac,
                  ngayBatDau: startDate ?? medicine.ngayBatDau,
                  ngayKetThuc: endDate ?? medicine.ngayKetThuc,
                );

                try {
                  await _apiService.capNhatLoiNhacThuoc(
                    updatedMedicine.toJson(),
                    medicine.maNhacNho,
                  );
                  setState(() {
                    _uongThuocData![index] = updatedMedicine;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cập nhật thuốc thành công')),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi cập nhật thuốc: $e')),
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

                  return GestureDetector(
                    onLongPress: () {
                      _showDeleteConfirmationDialog(
                        context,
                        item.maNhacNho,
                        index,
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
                              'Tên thuốc: ${item.tenThuoc}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('Liều lượng: ${item.lieuLuong}'),
                            Text('Thời gian nhắc: ${item.thoiGianNhac}'),
                            Text(
                              'Ngày bắt đầu: ${DateFormat('yyyy-MM-dd').format(item.ngayBatDau)}',
                            ),
                            Text(
                              'Ngày kết thúc: ${DateFormat('yyyy-MM-dd').format(item.ngayKetThuc)}',
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editMedicine(item, index),
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
    );
  }
}
