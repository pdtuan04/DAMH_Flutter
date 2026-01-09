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
                    // Image
                    Builder(
                      builder: (context) {
                        const String serverUrl = 'http://10.0.2.2:5084';
                        final String? rawUrl = chuDe.imageUrl;
                        final String imageUrl = (rawUrl != null && rawUrl.isNotEmpty)
                            ? (rawUrl.startsWith('http') ? rawUrl : '$serverUrl$rawUrl')
                            : '';

                        return imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                height: 150,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                              )
                            : const Icon(Icons.image, size: 100, color: Colors.blueAccent);
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
