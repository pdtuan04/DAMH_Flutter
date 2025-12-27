import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chu_de.dart';
import 'authenticate.dart';


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

  static Future<bool> create(ChuDe item) async {
    try {
      final token = await TokenService.getToken(); // Need import authenticate
      final Map<String, dynamic> body = {
        'tenChuDe': item.tenChuDe,
        'moTa': item.moTa,
        'imageUrl': item.imageUrl,
      };

      if (item.id.isNotEmpty) {
        body['id'] = item.id;
      }

      final res = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      if (res.statusCode == 200) return true;
      throw Exception(jsonDecode(res.body)['message'] ?? 'Lỗi thêm');
    } catch (e) {
      throw Exception("Lỗi: $e");
    }
  }

  static Future<bool> update(ChuDe item) async {
    try {
      final token = await TokenService.getToken();
      final res = await http.put(
        Uri.parse('$baseUrl/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id': item.id,
          'tenChuDe': item.tenChuDe,
          'moTa': item.moTa,
          'imageUrl': item.imageUrl,
        }),
      );
      if (res.statusCode == 200) return true;
      throw Exception(jsonDecode(res.body)['message'] ?? 'Lỗi cập nhật');
    } catch (e) {
      throw Exception("Lỗi: $e");
    }
  }

  static Future<bool> delete(String id) async {
    try {
      final token = await TokenService.getToken();
      final res = await http.delete(
        Uri.parse('$baseUrl/delete/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) return true;
      throw Exception(jsonDecode(res.body)['message'] ?? 'Lỗi xóa');
    } catch (e) {
      throw Exception("Lỗi: $e");
    }
  }
}
