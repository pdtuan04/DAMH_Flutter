class CauHoi {
  final String id;
  final String noiDung;
  final String luaChonA;
  final String luaChonB;
  final String? luaChonC;
  final String? luaChonD;
  final String dapAnDung;
  final String? mediaUrl;
  final String? giaiThich;
  //final bool diemLiet;
  CauHoi({
    required this.id,
    required this.noiDung,
    required this.luaChonA,
    required this.luaChonB,
    this.luaChonC,
    this.luaChonD,
    required this.dapAnDung,
    this.mediaUrl,
    this.giaiThich,
    //required this.diemLiet,
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
      giaiThich: json['giaiThich'],
      //diemLiet: json
    );
  }
}