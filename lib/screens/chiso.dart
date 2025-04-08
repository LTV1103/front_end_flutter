import 'package:flutter/material.dart';
import '../services/api.dart';

class ChiSoScreen extends StatefulWidget {
  final int userId;

  const ChiSoScreen({super.key, required this.userId});

  @override
  _ChiSoScreenState createState() => _ChiSoScreenState();
}

class _ChiSoScreenState extends State<ChiSoScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _dsChiSo = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final List<dynamic> data = await _apiService.layChiSoTheoId(
        widget.userId,
      );
      final List<Map<String, dynamic>> chiSoList =
          data.map((e) => Map<String, dynamic>.from(e)).toList();

      setState(() {
        _userData = chiSoList.isNotEmpty ? chiSoList[0] : null;
        _dsChiSo = chiSoList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')));
    }
  }

  Future<void> _themChiSo() async {
    final _formKey = GlobalKey<FormState>();
    final chieuCaoController = TextEditingController();
    final canNangController = TextEditingController();
    final huyetApController = TextEditingController();
    final nhipTimController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Thêm Chỉ Số Mới'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: chieuCaoController,
                      decoration: InputDecoration(labelText: 'Chiều cao (cm)'),
                      keyboardType: TextInputType.number,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Nhập chiều cao'
                                  : null,
                    ),
                    TextFormField(
                      controller: canNangController,
                      decoration: InputDecoration(labelText: 'Cân nặng (kg)'),
                      keyboardType: TextInputType.number,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Nhập cân nặng'
                                  : null,
                    ),
                    TextFormField(
                      controller: huyetApController,
                      decoration: InputDecoration(
                        labelText: 'Huyết áp (vd: 120/80)',
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Nhập huyết áp'
                                  : null,
                    ),
                    TextFormField(
                      controller: nhipTimController,
                      decoration: InputDecoration(labelText: 'Nhịp tim (bpm)'),
                      keyboardType: TextInputType.number,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Nhập nhịp tim'
                                  : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Huỷ'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final data = {
                      'chieu_cao': double.parse(chieuCaoController.text),
                      'can_nang': double.parse(canNangController.text),
                      'huyet_ap': huyetApController.text,
                      'nhip_tim': int.parse(nhipTimController.text),
                    };

                    try {
                      final response = await _apiService.themChiSo(
                        widget.userId.toString(),
                        data,
                      );
                      if (response['status'] == 'success') {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Thêm chỉ số thành công!')),
                        );
                        _fetchUserData();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Thất bại: ${response['message']}'),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi khi thêm chỉ số: $e')),
                      );
                    }
                  }
                },
                child: Text('Lưu'),
              ),
            ],
          ),
    );
  }

  void _xoaChiSoDialog(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Xoá chỉ số'),
            content: Text('Bạn có chắc muốn xoá chỉ số này không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Huỷ'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Xoá'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await _apiService.xoaChiSo(id);

        // Cập nhật danh sách ngay lập tức
        setState(() {
          _dsChiSo.removeWhere((chiSo) => chiSo['ma_chi_so'].toString() == id);
          _userData = _dsChiSo.isNotEmpty ? _dsChiSo[0] : null;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Xoá thành công')));

        // Tải lại dữ liệu từ API để đảm bảo đồng bộ
        _fetchUserData();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Xoá thất bại: $e')));
      }
    }
  }

  void _suaChiSoDialog(Map<String, dynamic> chiSo) async {
    final formKey = GlobalKey<FormState>();
    final chieuCao = TextEditingController(
      text: chiSo['chieu_cao_cm'].toString(),
    );
    final canNang = TextEditingController(
      text: chiSo['can_nang_kg'].toString(),
    );
    final huyetAp = TextEditingController(text: chiSo['huyet_ap'].toString());
    final nhipTim = TextEditingController(text: chiSo['nhip_tim'].toString());

    double? bmi;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            void _tinhBMI() {
              try {
                final cc = double.parse(chieuCao.text);
                final cn = double.parse(canNang.text);
                if (cc > 0 && cn > 0) {
                  final chieuCaoMet = cc / 100;
                  final tinhBmi = cn / (chieuCaoMet * chieuCaoMet);
                  setState(() {
                    bmi = double.parse(tinhBmi.toStringAsFixed(2));
                  });
                }
              } catch (_) {
                // không làm gì cả
              }
            }

            return AlertDialog(
              title: Text('Sửa chỉ số'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: chieuCao,
                      decoration: InputDecoration(labelText: 'Chiều cao (cm)'),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _tinhBMI(),
                    ),
                    TextFormField(
                      controller: canNang,
                      decoration: InputDecoration(labelText: 'Cân nặng (kg)'),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _tinhBMI(),
                    ),
                    TextFormField(
                      controller: huyetAp,
                      decoration: InputDecoration(labelText: 'Huyết áp'),
                    ),
                    TextFormField(
                      controller: nhipTim,
                      decoration: InputDecoration(labelText: 'Nhịp tim'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                    if (bmi != null) Text('BMI: ${bmi!.toStringAsFixed(2)}'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Huỷ'),
                ),
                TextButton(
                  child: Text('Lưu'),
                  onPressed: () async {
                    try {
                      final cc = double.parse(chieuCao.text);
                      final cn = double.parse(canNang.text);
                      final tinhBmi = cn / ((cc / 100) * (cc / 100));

                      final data = {
                        'chieu_cao': cc,
                        'can_nang': cn,
                        'huyet_ap': huyetAp.text,
                        'nhip_tim': int.parse(nhipTim.text),
                        'bmi': double.parse(tinhBmi.toStringAsFixed(2)),
                      };

                      final res = await _apiService.capNhatChiSo(
                        chiSo['ma_chi_so'],
                        data,
                      );

                      if (res['status'] == 'success') {
                        Navigator.pop(ctx);
                        _fetchUserData();
                      } else {
                        throw res['message'];
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi cập nhật: $e')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _userData == null
              ? Center(
                child: Text(
                  'Không có dữ liệu',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Card thông tin người dùng
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Image.asset(
                              _userData!['gioi_tinh'] == 'Nam'
                                  ? 'assets/man.jpg'
                                  : 'assets/female.jpg',
                              width: 200,
                              height: 200,
                            ),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Họ và Tên:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                Text(
                                  '${_userData!['ho_ten'] ?? 'Không có'}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Giới tính:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                Text(
                                  '${_userData!['gioi_tinh'] ?? 'Không có'}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Chỉ số sức khoẻ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    ..._dsChiSo.map(
                      (chiSo) => GestureDetector(
                        onTap: () => _suaChiSoDialog(chiSo),
                        onLongPress:
                            () =>
                                _xoaChiSoDialog(chiSo['ma_chi_so'].toString()),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ngày đo: ${_formatDate(chiSo['ngay_do'])}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                _buildInfoRow(
                                  'Chiều Cao:',
                                  '${chiSo['chieu_cao_cm']} cm',
                                  Colors.black,
                                ),
                                _buildInfoRow(
                                  'Cân Nặng:',
                                  '${chiSo['can_nang_kg']} kg',
                                  Colors.black,
                                ),
                                _buildInfoRow(
                                  'Huyết Áp:',
                                  '${chiSo['huyet_ap']}',
                                  Colors.black,
                                ),
                                _buildInfoRow(
                                  'Nhịp Tim:',
                                  '${chiSo['nhip_tim']} bpm',
                                  Colors.black,
                                ),
                                _buildInfoRow(
                                  'BMI:',
                                  '${chiSo['BMI']}',
                                  Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _themChiSo,
                      icon: Icon(Icons.add),
                      label: Text('Thêm Chỉ Số'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
  }
}
