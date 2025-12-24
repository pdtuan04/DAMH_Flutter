  import 'cau_hoi.dart';

class BaiThi {
  final String id;
  final String tenBaiThi;
  final List<ChiTietBaiThi> chiTietBaiThis;

  BaiThi({required this.id, required this.tenBaiThi, required this.chiTietBaiThis});

  factory BaiThi.fromJson(Map<String, dynamic> json) {
    return BaiThi(
      id: json['id'],
      tenBaiThi: json['tenBaiThi'],
      chiTietBaiThis: (json['chiTietBaiThis'] as List)
          .map((e) => ChiTietBaiThi.fromJson(e))
          .toList(),
    );
  }
}
class ChiTietBaiThi {
  final String id;
  final CauHoi? cauHoi; // Thay vì String cauHoiId

  ChiTietBaiThi({required this.id, required this.cauHoi});

  factory ChiTietBaiThi.fromJson(Map<String, dynamic> json) {
    return ChiTietBaiThi(
      id: json['id'],
      // Nếu json['cauHoi'] là null, trả về null luôn, không gọi fromJson để tránh crash
      cauHoi: json['cauHoi'] != null ? CauHoi.fromJson(json['cauHoi']) : null,
    );
  }
}
class KetQuaNopBai {
  final int soCauDung;
  final int tongSoCau;
  final double tongDiem;
  final String ketQua; // Đạt/Không đạt
  final List<ChiTietKetQua> ketQuaList;

  KetQuaNopBai({
    required this.soCauDung,
    required this.tongSoCau,
    required this.tongDiem,
    required this.ketQua,
    required this.ketQuaList,
  });

  factory KetQuaNopBai.fromJson(Map<String, dynamic> json) {
    return KetQuaNopBai(
      soCauDung: json['soCauDung'] ?? 0,
      tongSoCau: json['tongSoCau'] ?? 0,
      tongDiem: (json['tongDiem'] as num).toDouble(),
      ketQua: json['ketQua'] ?? '',
      ketQuaList: (json['ketQuaList'] as List)
          .map((e) => ChiTietKetQua.fromJson(e))
          .toList(),
    );
  }
}

class ChiTietKetQua {
  final String cauHoiId;
  final String cauTraLoi;
  final String dapAnDung;
  final bool dungSai;

  ChiTietKetQua({
    required this.cauHoiId,
    required this.cauTraLoi,
    required this.dapAnDung,
    required this.dungSai,
  });

  factory ChiTietKetQua.fromJson(Map<String, dynamic> json) {
    return ChiTietKetQua(
      cauHoiId: json['cauHoiId'] ?? '',
      cauTraLoi: json['cauTraLoi'] ?? '',
      dapAnDung: json['dapAnDung'] ?? '',
      dungSai: json['dungSai'] ?? false,
    );
  }
}