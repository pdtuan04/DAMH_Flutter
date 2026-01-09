import 'package:http/http.dart' as http;

class ChatService {
  // 10.0.2.2 là localhost cho Android Emulator
  static const String baseUrl = "http://10.0.2.2:5084/api/ChatBox";

  static Future<String> getAIResponse(String sessionId, String prompt) async {
    try {
      final url = Uri.parse('$baseUrl/get-response').replace(queryParameters: {
        'id': sessionId,
        'prompt': prompt,
      });

      final response = await http.get(url);
      if (response.statusCode == 200) {
        return response.body;
      }
      return "Lỗi server: ${response.statusCode}";
    } catch (e) {
      return "Lỗi kết nối server!";
    }
  }
}