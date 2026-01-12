class MoPhong {
  final String id;
  final String noiDung;
  final String videoUrl;
  final String dapAn;
  final String loaiBangLaiId;

  MoPhong({
    required this.id,
    required this.noiDung,
    required this.videoUrl,
    required this.dapAn,
    required this.loaiBangLaiId,
  });

  List<double> getDanhSachMocThoiGian() {
    if (dapAn.isEmpty) return [];
    try {
      return dapAn.split(',').map((e) => double.parse(e.trim())).toList();
    } catch (e) {
      return [];
    }
  }

   static String taoStringDapAn(List<double> mocThoiGian) {
    return mocThoiGian.join(',');
  }

  factory MoPhong.fromJson(Map<String, dynamic> json) {
    return MoPhong(
      id: json['id'] ?? '',
      noiDung: json['noiDung'] ?? 'Không có tiêu đề',
      videoUrl: json['videoUrl'] ?? '',
      dapAn: json['dapAn'] ?? '',
      loaiBangLaiId: json['loaiBangLaiId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'noiDung': noiDung,
      'videoUrl': videoUrl,
      'dapAn': dapAn,
      'loaiBangLaiId': loaiBangLaiId,
    };
  }
}