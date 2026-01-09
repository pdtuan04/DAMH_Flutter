class LoaiBangLai {
  final String id;
  final String tenLoai;
  final String moTa;
  final String loaiXe;
  final int thoiGianThi;
  final int diemToiThieu;

  LoaiBangLai({
    required this.id,
    required this.tenLoai,
    required this.moTa,
    required this.loaiXe,
    required this.thoiGianThi,
    required this.diemToiThieu,
  });

  factory LoaiBangLai.fromJson(Map<String, dynamic> json) {
    return LoaiBangLai(
      id: json['id'],
      tenLoai: json['tenLoai'],
      moTa: json['moTa'] ?? '',
      loaiXe: json['loaiXe'] ?? '',
      thoiGianThi: json['thoiGianThi'],
      diemToiThieu: json['diemToiThieu'],
    );
  }
}