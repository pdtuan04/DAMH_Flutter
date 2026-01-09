import 'package:flutter/material.dart';
import '../../../models/loai_bang_lai.dart';

class LoaiBangLaiDetail extends StatelessWidget {
  final LoaiBangLai loaiBangLai;

  const LoaiBangLaiDetail({Key? key, required this.loaiBangLai}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết loại bằng lái'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin loại bằng lái',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    _buildDetailRow('ID:', loaiBangLai.id),
                    const Divider(),
                    _buildDetailRow('Tên loại:', loaiBangLai.tenLoai),
                    const Divider(),
                    _buildDetailRow('Mô tả:', loaiBangLai.moTa),
                    const Divider(),
                    _buildDetailRow('Loại xe:', loaiBangLai.loaiXe),
                    const Divider(),
                    _buildDetailRow('Thời gian thi:', '${loaiBangLai.thoiGianThi} phút'),
                    const Divider(),
                    _buildDetailRow('Điểm tối thiểu:', '${loaiBangLai.diemToiThieu}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('Quay lại'),
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
