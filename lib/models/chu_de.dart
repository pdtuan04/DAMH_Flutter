class ChuDe {
  final String id;
  final String tenChuDe;
  final String moTa;
  final String? imageUrl;
  ChuDe({
    required this.id,
    required this.tenChuDe,
    required this.moTa,
    this.imageUrl
  });

  factory ChuDe.fromJson(Map<String, dynamic> json) {
    return ChuDe(
      id: json['id'],
      tenChuDe: json['tenChuDe'],
      moTa: json['moTa'],
      imageUrl: json['imageUrl'],
    );
  }
}