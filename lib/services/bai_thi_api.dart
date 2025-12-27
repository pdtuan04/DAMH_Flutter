import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/bai_thi.dart';

class ApiBaiThiService{

  static const String baseUrl = 'http://10.0.2.2:5084/api/BaiThi';
  static Future<List<BaiThi>> getAll() async{
    try{
      final res = await http.get(
        Uri.parse('$baseUrl/danh-sach-bai-thi'),
        headers: {'Content-Type': 'application/json'},
      );
      if(res.statusCode == 200){
        final List<dynamic> jsonList  = json.decode(res.body);
        return jsonList
            .map((e) => BaiThi.fromJson(e))
            .toList();
      }else {
        final errorData = json.decode(res.body);
        throw Exception(errorData['message'] ?? 'Lỗi khi tải danh sách bài thi');
      }
    }catch(e){
      throw Exception("Lỗi kết nối mạng");
    }
  }
  static Future<List<BaiThi>> getByLoaiBangLaiId(String id) async {
    try {
      final url = Uri.parse('$baseUrl/de-thi-by-id-lblai/$id');

      final res = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        // 2. Ép kiểu dữ liệu JSON sang List trước khi map
        final List<dynamic> jsonList = json.decode(res.body);

        return jsonList.map((e) => BaiThi.fromJson(e)).toList();
      } else {
        // 3. Trả về thông báo lỗi từ Server nếu có
        final errorData = json.decode(res.body);
        throw Exception(errorData['message'] ?? 'Không thể tải danh sách đề thi');
      }
    } catch (e) {
      // In ra console để bạn dễ dàng debug khi chạy app
      print("Lỗi API getByLoaiBangLaiId: $e");
      throw Exception("Lỗi kết nối mạng: $e");
    }
  }
  static Future<BaiThi> getById(String id) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/bai-thi/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final jsonData = json.decode(res.body);
        return BaiThi.fromJson(jsonData);
      } else {
        final errorData = json.decode(res.body);
        throw Exception(errorData['message'] ?? 'Lỗi khi tải bài thi');
      }
    } catch (e) {
      throw Exception("Lỗi kết nối mạng");
    }
  }
  // Thêm vào class ApiBaiThiService
  static Future<Map<String, dynamic>> submitResult(String baiThiId, Map<String, String> answers) async {
    try {
      const storage = FlutterSecureStorage();
      String? token = await storage.read(key: 'jwt_token');

      final response = await http.post(
        Uri.parse('$baseUrl/nop-bai-thi'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'baiThiId': baiThiId,
          'answers': answers,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Trả về dữ liệu kết quả
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Lỗi không xác định');
      }
    } catch (e) {
      throw Exception("Lỗi kết nối: $e");
    }
  }


  static Future<bool> create(String tenBaiThi, List<String> cauHoiIds) async {
    try {
      const storage = FlutterSecureStorage();
      String? token = await storage.read(key: 'jwt_token');

      final res = await http.post(
        Uri.parse('$baseUrl'), // POST /api/BaiThi
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'tenBaiThi': tenBaiThi,
          'chiTietBaiThis': cauHoiIds.map((id) => {'cauHoiId': id}).toList(),
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return true;
      } else {
        final error = jsonDecode(res.body);
        throw Exception(error['message'] ?? 'Lỗi tạo đề thi');
      }
    } catch (e) {
      throw Exception("Lỗi: $e");
    }
  }

  static Future<bool> delete(String id) async {
    try {
      const storage = FlutterSecureStorage();
      String? token = await storage.read(key: 'jwt_token');

      final res = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        return true;
      } else {
        final error = jsonDecode(res.body);
        throw Exception(error['message'] ?? 'Lỗi xóa đề thi');
      }
    } catch (e) {
      throw Exception("Lỗi: $e");
    }
  }
}