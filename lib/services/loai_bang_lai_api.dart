import 'dart:convert';
import 'package:damh_flutter/models/loai_bang_lai.dart';
import 'package:http/http.dart' as http;
import 'authenticate.dart';

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

  static Future<bool> create(LoaiBangLai item) async {
    try {
      final token = await TokenService.getToken();
    final Map<String, dynamic> body = {
          'tenLoai': item.tenLoai,
          'moTa': item.moTa,
          'loaiXe': item.loaiXe,
          'thoiGianThi': item.thoiGianThi,
          'diemToiThieu': item.diemToiThieu,
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

  static Future<bool> update(LoaiBangLai item) async {
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
          'tenLoai': item.tenLoai,
          'moTa': item.moTa,
          'loaiXe': item.loaiXe,
          'thoiGianThi': item.thoiGianThi,
          'diemToiThieu': item.diemToiThieu,
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