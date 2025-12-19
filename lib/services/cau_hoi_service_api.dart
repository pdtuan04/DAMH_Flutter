import 'dart:convert';

import 'package:damh_flutter/models/loai_bang_lai.dart';
import 'package:http/http.dart' as http;

import '../models/cau_hoi.dart';

class ApiCauHoiService{
  static const String baseUrl = 'http://10.0.2.2:5084/api/CauHoi';
  static Future<List<CauHoi>> getCauHoiOnTap(String loaiBangLaiId, String chuDeId) async {
    try {
      final url = Uri.parse('$baseUrl/get-cau-hoi-on-theo-chu-de?chuDeId=$chuDeId&loaiBangLaiId=$loaiBangLaiId');

      final res = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        // 1. Giải mã body thành Map
        final Map<String, dynamic> responseData = jsonDecode(res.body);

        // 2. Lấy danh sách từ trường 'data'
        final List<dynamic> list = responseData['data'];

        return list.map((e) => CauHoi.fromJson(e)).toList();
      } else {
        final error = jsonDecode(res.body);
        throw Exception(error['message'] ?? 'Lỗi không xác định khi load câu hỏi');
      }
    } catch (e) {
      // Log lỗi chi tiết để debug
      print("Lỗi API getCauHoiOnTap: $e");
      throw Exception("Lỗi kết nối mạng hoặc sai cấu trúc dữ liệu");
    }
  }
}