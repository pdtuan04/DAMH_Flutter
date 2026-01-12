import 'package:flutter/material.dart';
import '../models/bai_thi.dart';

class KetQuaBaiThiScreen extends StatelessWidget {
  final KetQuaNopBai ketQua;

  const KetQuaBaiThiScreen({super.key, required this.ketQua});

  @override
  Widget build(BuildContext context) {
    bool isPassed = ketQua.ketQua == "Đạt";

    return Scaffold(
      backgroundColor: Colors.grey[50], // Nền sáng dịu
      appBar: AppBar(
        title: const Text('Kết quả bài thi', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Phần tóm tắt điểm số (Header)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem("Câu đúng", "${ketQua.soCauDung}/${ketQua.tongSoCau}", Colors.white),
                _buildSummaryItem("Kết quả", ketQua.ketQua, isPassed ? Colors.greenAccent : Colors.orangeAccent),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Danh sách chi tiết từng câu
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: ketQua.ketQuaList.length,
              itemBuilder: (context, index) {
                final item = ketQua.ketQuaList[index];
                // Xử lý logic hiển thị khi đáp án bị null hoặc rỗng
                final String userChoice = (item.userDapAn == null || item.userDapAn!.isEmpty)
                    ? "Chưa chọn đáp án"
                    : item.userDapAn!;
                final bool isSkipped = item.userDapAn == null || item.userDapAn!.isEmpty;

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200), // Viền nhẹ cho Card
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Nội dung câu hỏi (Hiện rõ ràng nhất)
                          Text(
                            item.noiDung,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),

                          // 2. Câu trả lời của người dùng
                          Text(
                            "Bạn chọn: $userChoice",
                            style: TextStyle(
                              fontSize: 14,
                              // Đổi màu trực tiếp dựa trên đúng/sai/bỏ qua
                              color: isSkipped ? Colors.orange.shade700 : (item.dungSai ? Colors.green : Colors.red),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "Đáp án đúng: ${item.dapAnDung}",
                          style: TextStyle(color: Colors.blueGrey.shade600),
                        ),
                      ),
                      trailing: Icon(
                        item.dungSai ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: item.dungSai ? Colors.green : Colors.red,
                        size: 28,
                      ),
                    )
                  ),
                );
              },
            ),
          ),

          // Nút Quay lại ở dưới cùng
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "QUAY LẠI",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.white70)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}