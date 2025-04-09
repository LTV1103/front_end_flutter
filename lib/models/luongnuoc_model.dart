import 'package:intl/intl.dart';

class LuongNuoc {
  final int maLuongNuoc;
  final int maNguoiDung;
  final int luongMl;
  final DateTime thoiGianGhi;

  LuongNuoc({
    required this.maLuongNuoc,
    required this.maNguoiDung,
    required this.luongMl,
    required this.thoiGianGhi,
  });

  // Tạo đối tượng từ JSON
  factory LuongNuoc.fromJson(Map<String, dynamic> json) {
    return LuongNuoc(
      maLuongNuoc: json['ma_luong_nuoc'],
      maNguoiDung: json['ma_nguoi_dung'],
      luongMl: json['luong_ml'],
      thoiGianGhi: DateTime.parse(json['thoi_gian_ghi']),
    );
  }

  // Chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'ma_luong_nuoc': maLuongNuoc,
      'ma_nguoi_dung': maNguoiDung,
      'luong_ml': luongMl,
      'thoi_gian_ghi': DateFormat('yyyy-MM-ddTHH:mm:ss').format(thoiGianGhi),
    };
  }
}
