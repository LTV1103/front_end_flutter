import 'package:intl/intl.dart';

class NhatKy {
  final int maHoatDong;
  final String loaiHoatDong;
  final int thoiGianPhut;
  final String caloTieuHao;
  final DateTime ngayHoatDong;
  final int maNguoiDung; // Thêm mã người dùng

  NhatKy({
    required this.maHoatDong,
    required this.loaiHoatDong,
    required this.thoiGianPhut,
    required this.caloTieuHao,
    required this.ngayHoatDong,
    required this.maNguoiDung, // Thêm mã người dùng
  });

  factory NhatKy.fromJson(Map<String, dynamic> json) {
    return NhatKy(
      maHoatDong: json['ma_hoat_dong'],
      loaiHoatDong: json['loai_hoat_dong'] ?? 'Không có',
      thoiGianPhut: json['thoi_gian_phut'] ?? 0,
      caloTieuHao: json['calo_tieu_hao'] ?? 0,
      ngayHoatDong: DateTime.parse(json['ngay_hoat_dong']),
      maNguoiDung: json['ma_nguoi_dung'] ?? 0, // Thêm mã người dùng
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ma_hoat_dong': maHoatDong,
      'loai_hoat_dong': loaiHoatDong,
      'thoi_gian_phut': thoiGianPhut,
      'calo_tieu_hao': caloTieuHao,
      'ngay_hoat_dong': DateFormat('yyyy-MM-dd').format(ngayHoatDong),
      'ma_nguoi_dung': maNguoiDung, // Thêm mã người dùng
    };
  }
}
