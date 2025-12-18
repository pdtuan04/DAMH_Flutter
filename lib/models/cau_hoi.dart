class CauHoi {
  final String id;
  final String noiDung;
  final String? luaChonA;
  final String? luaChonB;
  final String? luaChonC;
  final String? luaChonD;
  final String dapAnDung;
  final String? mediaUrl;

  CauHoi({
    required this.id,
    required this.noiDung,
    this.luaChonA,
    this.luaChonB,
    this.luaChonC,
    this.luaChonD,
    required this.dapAnDung,
    this.mediaUrl,
  });

  factory CauHoi.fromJson(Map<String, dynamic> json) {
    return CauHoi(
      id: json['id'],
      noiDung: json['noiDung'],
      luaChonA: json['luaChonA'],
      luaChonB: json['luaChonB'],
      luaChonC: json['luaChonC'],
      luaChonD: json['luaChonD'],
      dapAnDung: json['dapAnDung'],
      mediaUrl: json['mediaUrl'],
    );
  }
}