import 'dart:io' as java_io;
import 'package:flutter/material.dart';
import '../../../models/chu_de.dart';

class ChuDeDetail extends StatelessWidget {
  final ChuDe chuDe;

  const ChuDeDetail({Key? key, required this.chuDe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết chủ đề'),
        backgroundColor: Colors.blue, 
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Builder(
                      builder: (context) {
                        final String? rawUrl = chuDe.imageUrl;
                        if (rawUrl == null || rawUrl.isEmpty) {
                          return const Icon(Icons.image, size: 100, color: Colors.blueAccent);
                        }

                        // Local file check: simply check if it doesn't start with http
                        // This covers /data/user..., /sdcard/..., or relative paths that we treat as potential files (or will fail gracefully)
                        bool isLocalFile = !rawUrl.startsWith('http');
                           
                        if (isLocalFile) {
                           return Image.file(
                               java_io.File(rawUrl),
                               height: 300, // Tăng kích thước theo yêu cầu
                               width: double.infinity,
                               fit: BoxFit.contain, // Giữ tỷ lệ ảnh, hiển thị rõ ràng
                               errorBuilder: (_, __, ___) => const Column(
                                 children: [
                                   Icon(Icons.broken_image, size: 80, color: Colors.red),
                                   Text("Ảnh lỗi hoặc không tìm thấy", style: TextStyle(color: Colors.grey)),
                                 ],
                               ),
                           );
                        }

                        const String serverUrl = 'http://10.0.2.2:5084';
                        final String imageUrl = rawUrl.startsWith('http') ? rawUrl : '$serverUrl$rawUrl';

                        return Image.network(
                                imageUrl,
                                height: 300, // Tăng kích thước theo yêu cầu
                                width: double.infinity,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                              );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Title
                    Text(
                      chuDe.tenChuDe,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    // ID
                    Text(
                      'Mã số: ${chuDe.id}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Description Header
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Mô tả', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),

                    // Description Content
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(chuDe.moTa),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Bottom Buttons
            Row(
              children: [
                 Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                       foregroundColor: Colors.white,
                       padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Quay lại danh sách'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
