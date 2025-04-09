import 'package:intl/intl.dart';

class UongThuoc {
  final int maNhacNho;
  final int maNguoiDung;
  final String tenThuoc;
  final String lieuLuong;
  final String thoiGianNhac;
  final DateTime ngayBatDau;
  final DateTime ngayKetThuc;

  UongThuoc({
    required this.maNhacNho,
    required this.maNguoiDung,
    required this.tenThuoc,
    required this.lieuLuong,
    required this.thoiGianNhac,
    required this.ngayBatDau,
    required this.ngayKetThuc,
  });

  // Tạo đối tượng từ JSON
  factory UongThuoc.fromJson(Map<String, dynamic> json) {
    return UongThuoc(
      maNhacNho: json['ma_nhac_nho'],
      maNguoiDung: json['ma_nguoi_dung'],
      tenThuoc: json['ten_thuoc'],
      lieuLuong: json['lieu_luong'],
      thoiGianNhac: json['thoi_gian_nhac'],
      ngayBatDau: DateTime.parse(json['ngay_bat_dau']),
      ngayKetThuc: DateTime.parse(json['ngay_ket_thuc']),
    );
  }

  // Chuyển đối tượng thành JSON
  Map<String, dynamic> toJson({bool includeId = true}) {
    final data = {
      'ma_nguoi_dung': maNguoiDung,
      'ten_thuoc': tenThuoc,
      'lieu_luong': lieuLuong,
      'thoi_gian_nhac': thoiGianNhac,
      'ngay_bat_dau': DateFormat(
        'yyyy-MM-dd',
      ).format(ngayBatDau), // Định dạng ngày
      'ngay_ket_thuc': DateFormat(
        'yyyy-MM-dd',
      ).format(ngayKetThuc), // Định dạng ngày
    };

    if (includeId) {
      data['ma_nhac_nho'] = maNhacNho;
    }

    return data;
  }
}
