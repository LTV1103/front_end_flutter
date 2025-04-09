import 'package:flutter/material.dart';
import '../services/api.dart';
import '../models/chiso_model.dart';

class ChiSoScreen extends StatefulWidget {
  final int userId;

  const ChiSoScreen({super.key, required this.userId});

  @override
  _ChiSoScreenState createState() => _ChiSoScreenState();
}

class _ChiSoScreenState extends State<ChiSoScreen> {
  final ApiService _apiService = ApiService();
  ChiSo? _userData;
  List<ChiSo> _dsChiSo = [];
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
      final List<ChiSo> chiSoList = data.map((e) => ChiSo.fromJson(e)).toList();

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
    final formKey = GlobalKey<FormState>();
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
              key: formKey,
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
                  if (formKey.currentState!.validate()) {
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

  void _xoaChiSoDialog(int id) async {
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
        final response = await _apiService.xoaChiSo(id);

        if (response['status'] == 'success') {
          // Cập nhật danh sách ngay lập tức
          setState(() {
            _dsChiSo.removeWhere((chiSo) => chiSo.maChiSo == id);
            _userData = _dsChiSo.isNotEmpty ? _dsChiSo[0] : null;
          });

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Xoá thành công')));

          // Tải lại dữ liệu từ API để đảm bảo đồng bộ
          _fetchUserData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Xoá thất bại: ${response['message']}')),
          );
        }
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
    final huyetAp = TextEditingController(
      text: chiSo['huyet_ap']?.toString() ?? '',
    );
    final nhipTim = TextEditingController(text: chiSo['nhip_tim'].toString());

    double? bmi;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            void tinhBMI() {
              try {
                final cc = double.tryParse(chieuCao.text);
                final cn = double.tryParse(canNang.text);
                if (cc != null && cc > 0 && cn != null && cn > 0) {
                  final bmiVal = cn / ((cc / 100) * (cc / 100));
                  setState(() {
                    bmi = double.parse(bmiVal.toStringAsFixed(2));
                  });
                } else {
                  setState(() {
                    bmi = null;
                  });
                }
              } catch (_) {
                setState(() {
                  bmi = null;
                });
              }
            }

            return AlertDialog(
              title: Text('Sửa chỉ số'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: chieuCao,
                        decoration: InputDecoration(
                          labelText: 'Chiều cao (cm)',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => tinhBMI(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nhập chiều cao';
                          }
                          final parsed = double.tryParse(value);
                          if (parsed == null || parsed <= 0) {
                            return 'Chiều cao không hợp lệ';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: canNang,
                        decoration: InputDecoration(labelText: 'Cân nặng (kg)'),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => tinhBMI(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nhập cân nặng';
                          }
                          final parsed = double.tryParse(value);
                          if (parsed == null || parsed <= 0) {
                            return 'Cân nặng không hợp lệ';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: huyetAp,
                        decoration: InputDecoration(
                          labelText: 'Huyết áp (vd: 120/80)',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nhập huyết áp';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: nhipTim,
                        decoration: InputDecoration(labelText: 'Nhịp tim'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nhập nhịp tim';
                          }
                          final parsed = int.tryParse(value);
                          if (parsed == null || parsed <= 0) {
                            return 'Nhịp tim không hợp lệ';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      if (bmi != null)
                        Text(
                          'BMI: ${bmi!.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Huỷ'),
                ),
                ElevatedButton(
                  child: Text('Lưu'),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
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
                        data,
                        chiSo['ma_chi_so'],
                      );

                      if (res['status'] == 'success') {
                        Navigator.pop(ctx);
                        _fetchUserData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Cập nhật thành công')),
                        );
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
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Image.asset(
                              _userData!.gioiTinh == 'Nam'
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
                                  '${_userData!.hoTen}',
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
                                  '${_userData!.gioiTinh}',
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
                        onTap: () => _suaChiSoDialog(chiSo.toJson()),
                        onLongPress: () => _xoaChiSoDialog(chiSo.maChiSo),
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
                                  'Ngày đo: ${_formatDate(chiSo.ngayDo)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.teal,
                                  ),
                                ),
                                SizedBox(height: 8),
                                _buildInfoRow(
                                  'Chiều Cao:',
                                  '${chiSo.chieuCaoCm} cm',
                                  Colors.blueAccent,
                                ),
                                _buildInfoRow(
                                  'Cân Nặng:',
                                  '${chiSo.canNangKg} kg',
                                  Colors.blueAccent,
                                ),
                                _buildInfoRow(
                                  'Huyết Áp:',
                                  '${chiSo.huyetAp}',
                                  Colors.blueAccent,
                                ),
                                _buildInfoRow(
                                  'Nhịp Tim:',
                                  '${chiSo.nhipTim} bpm',
                                  Colors.blueAccent,
                                ),
                                _buildInfoRow(
                                  'BMI:',
                                  '${chiSo.bmi}',
                                  Colors.green,
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
