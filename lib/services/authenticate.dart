import 'dart:convert';

import 'package:damh_flutter/models/bai_thi.dart';
import 'package:damh_flutter/models/login.dart';
import 'package:damh_flutter/models/register.dart';
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