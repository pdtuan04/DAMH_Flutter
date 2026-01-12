import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'authenticate.dart';

class UserApiService {
  static const String baseUrl = 'http://10.0.2.2:5084/api/Manager';

  // Lấy danh sách user có phân trang
  static Future<UserPagedResponse> getPagedUsers({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? sortCol,
    String? sortDir,
  }) async {
    try {
      final token = await TokenService.getToken();
      
      final queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (sortCol != null) 'sortCol': sortCol,
        if (sortDir != null) 'sortDir': sortDir,
      };

      final uri = Uri.parse('$baseUrl/paged-users').replace(queryParameters: queryParams);
      
      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        return UserPagedResponse.fromJson(jsonData);
      } else {
        throw Exception('Lỗi server: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Lấy thông tin user theo ID
  static Future<User> getUserById(String id) async {
    try {
      final token = await TokenService.getToken();
      
      final res = await http.get(
        Uri.parse('$baseUrl/get-user-by-id/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        if (jsonData['status'] == true) {
          return User.fromJson(jsonData['data']);
        }
        throw Exception(jsonData['message'] ?? 'Lỗi lấy thông tin user');
      } else {
        throw Exception('Lỗi server: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Lấy danh sách roles
  static Future<List<Role>> getRoleList() async {
    try {
      final token = await TokenService.getToken();
      
      final res = await http.get(
        Uri.parse('$baseUrl/role-list'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        if (jsonData['status'] == true) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => Role.fromJson(item)).toList();
        }
        throw Exception(jsonData['message'] ?? 'Lỗi lấy danh sách role');
      } else {
        throw Exception('Lỗi server: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Cập nhật role của user
  static Future<bool> setUserRole(String userId, String roleName) async {
    try {
      final token = await TokenService.getToken();
      
      final res = await http.post(
        Uri.parse('$baseUrl/set-role-user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(roleName),
      );

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        return jsonData['status'] == true;
      }
      return false;
    } catch (e) {
      throw Exception('Lỗi cập nhật role: $e');
    }
  }
}