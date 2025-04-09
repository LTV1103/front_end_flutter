class ChiSo {
  final int maChiSo;
  final String chieuCaoCm;
  final String canNangKg;
  final String huyetAp;
  final int nhipTim;
  final int bmi;
  final String ngayDo;
  final String hoTen; // Họ tên người dùng
  final String gioiTinh; // Giới tính người dùng

  ChiSo({
    required this.maChiSo,
    required this.chieuCaoCm,
    required this.canNangKg,
    required this.huyetAp,
    required this.nhipTim,
    required this.bmi,
    required this.ngayDo,
    required this.hoTen,
    required this.gioiTinh,
  });

  factory ChiSo.fromJson(Map<String, dynamic> json) {
    return ChiSo(
      maChiSo: json['ma_chi_so'],
      chieuCaoCm: json['chieu_cao_cm'],
      canNangKg: json['can_nang_kg'],
      huyetAp: json['huyet_ap'] ?? '',
      nhipTim: json['nhip_tim'],
      bmi: json['BMI'],
      ngayDo: json['ngay_do'],
      hoTen: json['ho_ten'], // Lấy họ tên từ JSON
      gioiTinh: json['gioi_tinh'], // Lấy giới tính từ JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ma_chi_so': maChiSo,
      'chieu_cao_cm': chieuCaoCm,
      'can_nang_kg': canNangKg,
      'huyet_ap': huyetAp,
      'nhip_tim': nhipTim,
      'BMI': bmi,
      'ngay_do': ngayDo,
      'ho_ten': hoTen, // Thêm họ tên vào JSON
      'gioi_tinh': gioiTinh, // Thêm giới tính vào JSON
    };
  }
}
