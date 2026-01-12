import 'package:flutter/material.dart';
import '../../../models/mo_phong.dart';

class MoPhongDetail extends StatelessWidget {
  final MoPhong moPhong;

  const MoPhongDetail({Key? key, required this.moPhong}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mocThoiGian = moPhong.getDanhSachMocThoiGian();
    
    // Tính điểm cho mỗi khoảng
    final diem = [5, 4, 3, 2, 1];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Mô Phỏng'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ID
            _buildInfoRow('ID', moPhong.id),
            const Divider(),

            // Nội dung
            _buildInfoRow('Nội dung', moPhong.noiDung),
            const Divider(),

            // Video URL
            _buildInfoRow('Link Video', moPhong.videoUrl),
            const Divider(),

            // Đáp án (chuỗi gốc)
            _buildInfoRow('Đáp án', moPhong.dapAn),
            const Divider(),

            // Loại bằng lái ID
            _buildInfoRow('Loại Bằng Lái ID', moPhong.loaiBangLaiId),
            const Divider(),

            const SizedBox(height: 16),

            // Chi tiết các mốc thời gian
            const Text(
              'Chi tiết các khoảng thời gian:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            if (mocThoiGian.length == 6)
              ...List.generate(5, (index) {
                final batDau = mocThoiGian[index];
                final ketThuc = mocThoiGian[index + 1];
                final diemKhoang = diem[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: _getColorByScore(diemKhoang).withOpacity(0.1),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getColorByScore(diemKhoang),
                      child: Text(
                        '${diemKhoang}đ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      'Khoảng ${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Từ ${batDau.toStringAsFixed(1)}s đến ${ketThuc.toStringAsFixed(1)}s',
                    ),
                    trailing: Text(
                      '${(ketThuc - batDau).toStringAsFixed(1)}s',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              })
            else
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text('Đáp án không đúng định dạng (phải có 6 mốc thời gian)'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Lấy màu theo điểm
  Color _getColorByScore(int score) {
    switch (score) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.red;
      case 3:
        return Colors.yellow.shade700;
      case 2:
        return Colors.blue;
      case 1:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}