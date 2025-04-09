class GiacNgu {
  final int maGhiChep;
  final int maNguoiDung;
  final DateTime thoiGianBatDau;
  final DateTime thoiGianKetThuc;
  final String? chatLuongGiacNgu;

  GiacNgu({
    required this.maGhiChep,
    required this.maNguoiDung,
    required this.thoiGianBatDau,
    required this.thoiGianKetThuc,
    this.chatLuongGiacNgu,
  });

  // Tạo đối tượng từ JSON
  factory GiacNgu.fromJson(Map<String, dynamic> json) {
    return GiacNgu(
      maGhiChep: json['ma_ghi_chep'],
      maNguoiDung: json['ma_nguoi_dung'],
      thoiGianBatDau: DateTime.parse(json['thoi_gian_bat_dau']),
      thoiGianKetThuc: DateTime.parse(json['thoi_gian_ket_thuc']),
      chatLuongGiacNgu: json['chat_luong_giac_ngu'],
    );
  }

  // Chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'ma_ghi_chep': maGhiChep,
      'ma_nguoi_dung': maNguoiDung,
      'thoi_gian_bat_dau': thoiGianBatDau.toIso8601String(),
      'thoi_gian_ket_thuc': thoiGianKetThuc.toIso8601String(),
      'chat_luong_giac_ngu': chatLuongGiacNgu,
    };
  }
}