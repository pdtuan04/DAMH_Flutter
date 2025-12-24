class MoPhong {
  final String id;
  final String noiDung;
  final String videoUrl;
  final String dapAn;

  MoPhong({
    required this.id,
    required this.noiDung,
    required this.videoUrl,
    required this.dapAn
  });

  factory MoPhong.fromJson(Map<String, dynamic> json) {
    return MoPhong(
      id: json['id'] ?? '',
      noiDung: json['noiDung'] ?? 'Không có tiêu đề',
      videoUrl: json['videoUrl'] ?? '',
      dapAn: json['dapAn'] ?? '',
    );
  }
}