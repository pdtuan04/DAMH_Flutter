class ChuDe {
  final String id;
  final String tenChuDe;
  final String moTa;

  ChuDe({
    required this.id,
    required this.tenChuDe,
    required this.moTa,
  });

  factory ChuDe.fromJson(Map<String, dynamic> json) {
    return ChuDe(
      id: json['id'],
      tenChuDe: json['tenChuDe'],
      moTa: json['moTa'],
    );
  }
}