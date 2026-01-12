import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class UploadService {
  // Endpoint chính xác lấy từ UploadController.cs
  static const String _uploadUrl = 'http://10.0.2.2:5084/api/Upload/upload-image';

  /// Upload ảnh lên server
  /// Trả về đường dẫn (URL relative) của ảnh trên server nếu thành công
  static Future<String?> uploadImage(File file) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      
      // Param name là 'file'
      request.files.add(await http.MultipartFile.fromPath(
        'file', 
        file.path,
        filename: path.basename(file.path),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Controller trả về: { status: true, message: "...", filePath: "..." }
        try {
           final body = jsonDecode(response.body);
           if (body is Map) {
             if (body['status'] == true && body.containsKey('filePath')) {
               return body['filePath'];
             } else {
               print("Upload failed logical: ${body['message']}");
               return null;
             }
           }
           // Fallback
           return body.toString(); 
        } catch (e) {
           print("Error parsing response: $e");
           return response.body; 
        }
      } else {
        print("Upload failed: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }
}
