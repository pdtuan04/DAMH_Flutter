import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chu_de.dart';


class ApiChuDeService {
  static const String baseUrl = 'http://10.0.2.2:5084/api/ChuDe';
  static Future<List<ChuDe>> getAll() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/danh-sach'),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(res.body);
        return jsonList.map((e) => ChuDe.fromJson(e)).toList();
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ?? "Lỗi tải danh sách chủ đề");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối mạng: $e");
    }
  }

  static Future<ChuDe> getById(String id) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/get/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        return ChuDe.fromJson(jsonData["data"]);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ?? "Lỗi tải chủ đề");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối mạng: $e");
    }
  }
}
