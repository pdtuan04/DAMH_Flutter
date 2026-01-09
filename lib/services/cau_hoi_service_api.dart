import 'dart:convert';
import 'package:damh_flutter/models/loai_bang_lai.dart';
import 'package:http/http.dart' as http;
import '../models/cau_hoi.dart';
import 'authenticate.dart';

class ApiCauHoiService {
  static const String baseUrl = 'http://10.0.2.2:5084/api/CauHoi';
  static Future<List<CauHoi>> getCauHoiOnTap(
    String loaiBangLaiId,
    String chuDeId,
  ) async {
    try {
      // 1. Thêm page=1&pageSize=1000 để đảm bảo lấy được dữ liệu bất kể backend chạy bản nào
      final url = Uri.parse(
        '$baseUrl/get-cau-hoi-on-theo-chu-de?chuDeId=$chuDeId&loaiBangLaiId=$loaiBangLaiId&page=1&pageSize=1000',
      );

      final res = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(res.body);

        // 2. Xử lý dữ liệu trả về (hỗ trợ cả 2 trường hợp List và Map)
        var data = responseData['data'];
        List<dynamic> list;

        if (data is List) {
          list = data;
        } else if (data is Map && data.containsKey('items')) {
          list = data['items'];
        } else {
          list = [];
        }

        return list.map((e) => CauHoi.fromJson(e)).toList();
      } else {
        final error = jsonDecode(res.body);
        throw Exception(
          error['message'] ?? 'Lỗi không xác định khi load câu hỏi',
        );
      }
    } catch (e) {
      print("Lỗi API getCauHoiOnTap: $e");
      throw Exception("Lỗi kết nối mạng hoặc sai cấu trúc dữ liệu");
    }
  }

  static Future<Map<String, dynamic>> getPagedCauHoi(
    int page,
    int pageSize, {
    String? search,
  }) async {
    try {
      String urlStr = '$baseUrl/paged-cau-hois?page=$page&pageSize=$pageSize';
      if (search != null && search.isNotEmpty) {
        urlStr += '&search=$search';
      }

      final res = await http.get(
        Uri.parse(urlStr),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        final List<dynamic> items = responseData['data'];
        final List<CauHoi> cauHois = items
            .map((e) => CauHoi.fromJson(e))
            .toList();

        return {
          'items': cauHois,
          'totalCount': responseData['recordsTotal'] ?? 0,
        };
      } else {
        throw Exception('Lỗi tải danh sách câu hỏi');
      }
    } catch (e) {
      throw Exception("Lỗi kết nối mạng: $e");
    }
  }

  static Future<bool> createCauHoi(CauHoi cauHoi) async {
    try {
      final token = await TokenService.getToken();
      final Map<String, dynamic> body = cauHoi.toJson();
      if (cauHoi.id.isEmpty) {
        body.remove('id');
      }
      final res = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        return true;
      } else {
        final error = jsonDecode(res.body);
        throw Exception(error['message'] ?? 'Lỗi thêm câu hỏi');
      }
    } catch (e) {
      throw Exception("Lỗi: $e");
    }
  }

  static Future<bool> updateCauHoi(CauHoi cauHoi) async {
    try {
      final token = await TokenService.getToken();
      final res = await http.put(
        Uri.parse('$baseUrl/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(cauHoi.toJson()),
      );

      if (res.statusCode == 200) {
        return true;
      } else {
        final error = jsonDecode(res.body);
        throw Exception(error['message'] ?? 'Lỗi cập nhật câu hỏi');
      }
    } catch (e) {
      throw Exception("Lỗi: $e");
    }
  }

  static Future<bool> deleteCauHoi(String id) async {
    try {
      final token = await TokenService.getToken();
      final res = await http.delete(
        Uri.parse('$baseUrl/delete/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        return true;
      } else {
        final error = jsonDecode(res.body);
        throw Exception(error['message'] ?? 'Lỗi xóa câu hỏi');
      }
    } catch (e) {
      throw Exception("Lỗi: $e");
    }
  }
  static Future<List<CauHoi>> getCauHoiHaySai(int soLuong) async {
    try {
      final url = Uri.parse('$baseUrl/get-cau-hoi-hay-sai?soLuong=${soLuong}');

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
  static Future<List<CauHoi>> getAll() async {
    try {
      final url = Uri.parse('$baseUrl/get-all-cau-hoi');

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
