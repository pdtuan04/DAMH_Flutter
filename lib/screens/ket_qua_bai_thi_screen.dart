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
                      leading: CircleAvatar(
                        backgroundColor: item.dungSai ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        child: Text(
                          "${index + 1}",
                          style: TextStyle(
                              color: item.dungSai ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      title: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black87, fontSize: 15),
                          children: [
                            const TextSpan(text: "Bạn chọn: "),
                            TextSpan(
                              text: userChoice,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSkipped ? Colors.orange.shade700 : (item.dungSai ? Colors.green : Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          "Đáp án đúng: ${item.dapAnDung}",
                          style: TextStyle(color: Colors.blueGrey.shade600),
                        ),
                      ),
                      trailing: Icon(
                        item.dungSai ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: item.dungSai ? Colors.green : Colors.red,
                      ),
                    ),
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