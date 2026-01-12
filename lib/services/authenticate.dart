import 'dart:convert';

import 'package:damh_flutter/models/bai_thi.dart';
import 'package:damh_flutter/models/login.dart';
import 'package:damh_flutter/models/register.dart';
import 'package:damh_flutter/models/user.dart';
import 'package:damh_flutter/models/lich_su_thi.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Authenticate{
  static const String baseUrl = 'http://10.0.2.2:5084/api/Authenticate';
  static Future<LoginResponse> login(LoginRequest request) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson())
      );

      if (res.statusCode == 200) {
        final jsonData = json.decode(res.body);
        return LoginResponse.fromJson(jsonData);
      } else {
        final errorData = json.decode(res.body);
        throw Exception(errorData['message'] ?? 'Lỗi đăng nhập');
      }
    } catch (e) {
      throw Exception("Lỗi kết nối mạng");
    }
  }
  static Future<bool> register(RegisterRequest request) async{
    try{
      final res = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson())
      );
      if(res.statusCode == 200){
        return true;
      }else{
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ?? 'Lỗi đăng ký');
      }
    }catch(e){
      throw Exception("Lỗi kết nối mạng");
    }
  }
  static Future<User> userProfile() async {
    String? token = await TokenService.getToken();
    try{
      final res = await http.post(
          Uri.parse('$baseUrl/user-profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
      );

      if(res.statusCode == 200){
        final jsonData = json.decode(res.body);
        return User.fromJson(jsonData);
      }else{
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ?? 'Lỗi đăng ký');
      }
    }catch(e){
      throw Exception("Lỗi kết nối mạng");
    }

  }

  static Future<Map<String, dynamic>> getLichSuThi({int pageNumber = 1, int pageSize = 10}) async {
  String? token = await TokenService.getToken();
  try {
    // Thử endpoint trực tiếp không qua baseUrl của Authenticate
    final res = await http.get(
      Uri.parse('http://10.0.2.2:5084/api/LichSuThi/get-history?pageNumber=$pageNumber&pageSize=$pageSize'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Status Code: ${res.statusCode}');
    print('Response Body: ${res.body}');

    if (res.statusCode == 200) {
      final jsonData = json.decode(res.body);
      
      if (jsonData['status'] == true) {
        final data = jsonData['data'];
        
        // Parse PageList response
        final items = (data['items'] as List?)?.map((item) => LichSuThi.fromJson(item)).toList() ?? [];
        
        return {
          'items': items,
          'totalCount': data['totalCount'] ?? 0,
          'pageNumber': data['pageNumber'] ?? 1,
          'pageSize': data['pageSize'] ?? 10,
          'totalPages': data['totalPages'] ?? 1,
        };
      }
      return {'items': [], 'totalCount': 0, 'pageNumber': 1, 'pageSize': 10, 'totalPages': 1};
    } else if (res.statusCode == 404) {
      // Nếu endpoint không tồn tại, trả về empty data thay vì throw error
      print('⚠Endpoint not found - returning empty data');
      return {'items': [], 'totalCount': 0, 'pageNumber': 1, 'pageSize': 10, 'totalPages': 1};
    } else {
      throw Exception('Lỗi server: ${res.statusCode}');
    }
  } catch (e) {
    print('Exception: $e');
    // Trả về empty data thay vì crash
    return {'items': [], 'totalCount': 0, 'pageNumber': 1, 'pageSize': 10, 'totalPages': 1};
  }
}

static Future<LichSuThiStats> getLichSuThiStats() async {
  String? token = await TokenService.getToken();
  try {
    final res = await http.get(
      Uri.parse('http://10.0.2.2:5084/api/LichSuThi/get-stats'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Stats Status Code: ${res.statusCode}');
    print('Stats Response Body: ${res.body}');

    if (res.statusCode == 200) {
      final jsonData = json.decode(res.body);
      
      if (jsonData['status'] == true) {
        return LichSuThiStats.fromJson(jsonData['data']);
      }
      // Trả về stats mặc định nếu không có data
      return LichSuThiStats(
        tongSoBaiThi: 0,
        soBaiThiDat: 0,
        soBaiThiKhongDat: 0,
        diemTrungBinh: 0,
        tyLeDung: 0,
      );
    } else if (res.statusCode == 404) {
      // Endpoint không tồn tại - trả về stats mặc định
      return LichSuThiStats(
        tongSoBaiThi: 0,
        soBaiThiDat: 0,
        soBaiThiKhongDat: 0,
        diemTrungBinh: 0,
        tyLeDung: 0,
      );
    } else {
      throw Exception('Lỗi server: ${res.statusCode}');
    }
  } catch (e) {
    print('Exception: $e');
    // Trả về stats mặc định
    return LichSuThiStats(
      tongSoBaiThi: 0,
      soBaiThiDat: 0,
      soBaiThiKhongDat: 0,
      diemTrungBinh: 0,
      tyLeDung: 0,
    );
  }
}
// Thêm vào file lib/services/authenticate.dart

static Future<LichSuThiDetail?> getChiTietLichSuThi(String lichSuThiId) async {
  String? token = await TokenService.getToken();
  try {
    print('Đang gọi API với ID: $lichSuThiId');
    print('Token: ${token?.substring(0, 20)}...');
    
    // SỬA: Đổi endpoint từ BaiThi sang LichSuThi
    final res = await http.get(
      Uri.parse('http://10.0.2.2:5084/api/LichSuThi/detail/$lichSuThiId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        print('Request timeout sau 10 giây');
        throw Exception('Request timeout');
      },
    );

    print('Chi tiết Status Code: ${res.statusCode}');
    print('Chi tiết Response: ${res.body}');

    if (res.statusCode == 200) {
      final jsonData = json.decode(res.body);
      print('JSON Data: $jsonData');
      
      // SỬA: Đổi từ 'success' sang 'status'
      if (jsonData['status'] == true && jsonData['data'] != null) {
        return LichSuThiDetail.fromJson(jsonData['data']);
      } else {
        print('Status = false hoặc data = null');
        return null;
      }
    } else if (res.statusCode == 401) {
      print('Unauthorized - Token hết hạn hoặc không hợp lệ');
      return null;
    } else if (res.statusCode == 404) {
      print('Not Found - Endpoint không tồn tại hoặc ID không tìm thấy');
      return null;
    } else {
      print('Lỗi khác: ${res.statusCode}');
      return null;
    }
  } catch (e, stackTrace) {
    print('Exception getting detail: $e');
    print('Stack trace: $stackTrace');
    return null;
  }
}
}

class TokenService {
  static const _storage = FlutterSecureStorage();
  static const _keyToken = 'jwt_token';

  // Lưu token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  // Đọc token
  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  // Xóa token (khi Đăng xuất)
  static Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }
}