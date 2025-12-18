class LoaiBangLai {
  final String id;
  final String tenLoai;
  final int thoiGianThi;
  final int diemToiThieu;

  LoaiBangLai({
    required this.id,
    required this.tenLoai,
    required this.thoiGianThi,
    required this.diemToiThieu,
  });

  factory LoaiBangLai.fromJson(Map<String, dynamic> json) {
    return LoaiBangLai(
      id: json['id'],
      tenLoai: json['tenLoai'],
      thoiGianThi: json['thoiGianThi'],
      diemToiThieu: json['diemToiThieu'],
    );
  }
}