import 'dart:convert';
import 'package:damh_flutter/models/mo_phong.dart';
import 'package:http/http.dart' as http;
import '../models/chu_de.dart';


class ApiMoPhongService {
  static const String baseUrl = 'http://10.0.2.2:5084/api/MoPhong';
  static Future<List<MoPhong>> getAll() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/get-all-mo-phong'),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(res.body);
        final List<dynamic> listData = jsonData['data'];
        return listData.map((e) => MoPhong.fromJson(e)).toList();
      } else {
        throw Exception("Lỗi server: ${res.statusCode}");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối mạng: $e");
    }
  }

  static Future<MoPhong> getById(String id) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        return MoPhong.fromJson(jsonData["data"]);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ?? "Lỗi tải mô phỏng");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối mạng: $e");
    }
  }
}
