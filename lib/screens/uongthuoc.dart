import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Thêm thư viện thông báo
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

  // Khởi tạo đối tượng thông báo
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications(); // Cấu hình thông báo
    _fetchUongThuocData();
  }

  // Cấu hình thông báo
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Icon thông báo

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Hiển thị thông báo
  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'medication_reminder_channel', // ID kênh
          'Nhắc nhở uống thuốc', // Tên kênh
          channelDescription: 'Thông báo nhắc nhở uống thuốc',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0, // ID thông báo
      title, // Tiêu đề
      body, // Nội dung
      platformChannelSpecifics,
    );
  }

  // Lấy dữ liệu nhắc nhở uống thuốc
  Future<void> _fetchUongThuocData() async {
    try {
      final data = await _apiService.layLoiNhacThuoc(widget.userId.toString());
      setState(() {
        _uongThuocData = data;
        _isLoading = false;
      });

      // Kiểm tra và hiển thị thông báo nếu thời gian nhắc trùng với hiện tại
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

  // Kiểm tra thời gian nhắc và hiển thị thông báo
  void _checkAndNotify() {
    final now = TimeOfDay.now(); // Lấy thời gian hiện tại
    for (var item in _uongThuocData ?? []) {
      final thoiGianNhac = item['thoi_gian_nhac']; // Thời gian nhắc từ API
      if (thoiGianNhac != null) {
        final parts = thoiGianNhac.split(':'); // Giả sử định dạng là HH:mm
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]);
          final minute = int.tryParse(parts[1]);
          if (hour == now.hour && minute == now.minute) {
            // Hiển thị thông báo
            _showNotification(
              'Nhắc nhở uống thuốc',
              'Đã đến giờ uống thuốc: ${item['ten_thuoc'] ?? 'Không có'}',
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nhắc nhở uống thuốc'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddMedicineDialog(context); // Hiển thị hộp thoại thêm mới
            },
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
                  return Card(
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
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Thời gian nhắc: ${item['thoi_gian_nhac'] ?? 'Không có'}',
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

  // Hộp thoại thêm mới thuốc
  void _showAddMedicineDialog(BuildContext context) {
    final tenThuocController = TextEditingController();
    final lieuLuongController = TextEditingController();
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Thêm mới thuốc'),
          content: Column(
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                if (tenThuocController.text.isNotEmpty &&
                    lieuLuongController.text.isNotEmpty &&
                    selectedTime != null) {
                  _addNewMedicine(
                    tenThuocController.text,
                    lieuLuongController.text,
                    selectedTime!,
                  );
                  Navigator.of(context).pop(); // Đóng hộp thoại
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

  // Hàm thêm mới thuốc
  void _addNewMedicine(String tenThuoc, String lieuLuong, TimeOfDay thoiGian) {
    final newMedicine = {
      'ten_thuoc': tenThuoc,
      'lieu_luong': lieuLuong,
      'thoi_gian_nhac':
          '${thoiGian.hour.toString().padLeft(2, '0')}:${thoiGian.minute.toString().padLeft(2, '0')}',
      'user_id': widget.userId, // Thêm userId nếu cần
    };

    // Gửi dữ liệu lên API
    _apiService
        .themLoiNhacThuoc(newMedicine)
        .then((response) {
          setState(() {
            _uongThuocData = (_uongThuocData ?? [])..add(newMedicine);
          });
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
}
