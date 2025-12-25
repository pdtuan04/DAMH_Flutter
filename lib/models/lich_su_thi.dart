class LichSuThi {
  final String id;
  final String baiThiId;
  final String tenBaiThi;
  final DateTime ngayThi;
  final int tongSoCau;
  final int soCauDung;
  final double phanTramDung;
  final int diem;
  final String ketQua;
  final bool macLoiNghiemTrong;

  LichSuThi({
    required this.id,
    required this.baiThiId,
    required this.tenBaiThi,
    required this.ngayThi,
    required this.tongSoCau,
    required this.soCauDung,
    required this.phanTramDung,
    required this.diem,
    required this.ketQua,
    required this.macLoiNghiemTrong,
  });

  factory LichSuThi.fromJson(Map<String, dynamic> json) {
    return LichSuThi(
      id: json['id'] ?? '',
      baiThiId: json['baiThiId'] ?? '',
      tenBaiThi: json['tenBaiThi'] ?? '',
      ngayThi: DateTime.parse(json['ngayThi'] ?? DateTime.now().toIso8601String()),
      tongSoCau: json['tongSoCau'] ?? 0,
      soCauDung: json['soCauDung'] ?? 0,
      phanTramDung: (json['phanTramDung'] ?? 0.0).toDouble(),
      diem: json['diem'] ?? 0,
      ketQua: json['ketQua'] ?? '',
      macLoiNghiemTrong: json['macLoiNghiemTrong'] ?? false,
    );
  }

  bool get isDat => ketQua == "Đạt";
}

class LichSuThiStats {
  final int tongSoBaiThi;
  final int soBaiThiDat;
  final int soBaiThiKhongDat;
  final double diemTrungBinh;
  final double tyLeDung;
  final LichSuThi? baiThiGanNhat;

  LichSuThiStats({
    required this.tongSoBaiThi,
    required this.soBaiThiDat,
    required this.soBaiThiKhongDat,
    required this.diemTrungBinh,
    required this.tyLeDung,
    this.baiThiGanNhat,
  });

  factory LichSuThiStats.fromJson(Map<String, dynamic> json) {
    return LichSuThiStats(
      tongSoBaiThi: json['tongSoBaiThi'] ?? 0,
      soBaiThiDat: json['soBaiThiDat'] ?? 0,
      soBaiThiKhongDat: json['soBaiThiKhongDat'] ?? 0,
      diemTrungBinh: (json['diemTrungBinh'] ?? 0.0).toDouble(),
      tyLeDung: (json['tyLeDung'] ?? 0.0).toDouble(),
      baiThiGanNhat: json['baiThiGanNhat'] != null 
          ? LichSuThi.fromJson(json['baiThiGanNhat']) 
          : null,
    );
  }
}
// Thêm vào file lib/models/lich_su_thi.dart

class ChiTietLichSuThi {
  final String cauHoiId;
  final String noiDung;
  final String luaChonA;
  final String luaChonB;
  final String luaChonC;
  final String luaChonD;
  final String dapAnDung;
  final String? cauTraLoi;
  final bool dungSai;
  final String? mediaUrl;
  final String? giaiThich;
  final bool diemLiet;

  ChiTietLichSuThi({
    required this.cauHoiId,
    required this.noiDung,
    required this.luaChonA,
    required this.luaChonB,
    required this.luaChonC,
    required this.luaChonD,
    required this.dapAnDung,
    this.cauTraLoi,
    required this.dungSai,
    this.mediaUrl,
    this.giaiThich,
    required this.diemLiet,
  });

  factory ChiTietLichSuThi.fromJson(Map<String, dynamic> json) {
    final cauHoi = json['cauHoi'];
    return ChiTietLichSuThi(
      cauHoiId: cauHoi['id'] ?? '',
      noiDung: cauHoi['noiDung'] ?? '',
      luaChonA: cauHoi['luaChonA'] ?? '',
      luaChonB: cauHoi['luaChonB'] ?? '',
      luaChonC: cauHoi['luaChonC'] ?? '',
      luaChonD: cauHoi['luaChonD'] ?? '',
      dapAnDung: cauHoi['dapAnDung'] ?? '',
      cauTraLoi: json['cauTraLoi']?.toString(),
      dungSai: json['dungSai'] ?? false,
      mediaUrl: cauHoi['mediaUrl'],
      giaiThich: cauHoi['giaiThich'],
      diemLiet: cauHoi['diemLiet'] ?? false,
    );
  }
}

class LichSuThiDetail {
  final LichSuThi lichSuThi;
  final List<ChiTietLichSuThi> chiTietList;

  LichSuThiDetail({
    required this.lichSuThi,
    required this.chiTietList,
  });

  factory LichSuThiDetail.fromJson(Map<String, dynamic> json) {
    return LichSuThiDetail(
      lichSuThi: LichSuThi.fromJson(json['lichSuThi']),
      chiTietList: (json['chiTietList'] as List?)
          ?.map((item) => ChiTietLichSuThi.fromJson(item))
          .toList() ?? [],
    );
  }
}