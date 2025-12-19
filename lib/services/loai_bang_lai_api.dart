import 'dart:convert';

import 'package:damh_flutter/models/loai_bang_lai.dart';
import 'package:http/http.dart' as http;

class ApiLoaiBangLaiService{
  static const String baseUrl = 'http://10.0.2.2:5084/api/LoaiBangLai';
  static Future<List<LoaiBangLai>> getAll() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/danh-sach'),
        headers: {'Content-Type': 'application/json'},
      );
      if (res.statusCode == 200) {
        // Ép kiểu jsonData thành List<dynamic>
        List<dynamic> jsonData = json.decode(res.body);

        // Sử dụng .from để tạo danh sách mới từ map
        return jsonData.map((item) => LoaiBangLai.fromJson(item)).toList();
      } else {
        throw Exception('Lỗi server: ${res.statusCode}');
      }
    } catch (e) {
      print("Lỗi tải loại bằng lái: $e"); // Debug lỗi ra console
      throw Exception("Lỗi kết nối mạng: $e");
    }
  }
}