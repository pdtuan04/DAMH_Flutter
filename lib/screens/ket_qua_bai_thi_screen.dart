import 'package:flutter/material.dart';

import '../models/bai_thi.dart';

class KetQuaBaiThiScreen extends StatelessWidget {
  final KetQuaNopBai ketQua;

  const KetQuaBaiThiScreen({super.key, required this.ketQua});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả bài thi'), backgroundColor: Colors.deepPurpleAccent),
      body: Column(
        children: [
          // Phần tóm tắt điểm số
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.deepPurple.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem("Đúng", "${ketQua.soCauDung}/${ketQua.tongSoCau}", Colors.green),
                _buildSummaryItem("Điểm", ketQua.tongDiem.toString(), Colors.blue),
                _buildSummaryItem("Kết quả", ketQua.ketQua, ketQua.ketQua == "Đạt" ? Colors.green : Colors.red),
              ],
            ),
          ),
          const Divider(height: 1),
          // Danh sách chi tiết từng câu
          Expanded(
            child: ListView.builder(
              itemCount: ketQua.ketQuaList.length,
              itemBuilder: (context, index) {
                final item = ketQua.ketQuaList[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: item.dungSai ? Colors.green : Colors.red,
                    child: Text("${index + 1}", style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text("Bạn chọn: ${item.cauTraLoi}"),
                  subtitle: Text("Đáp án đúng: ${item.dapAnDung}"),
                  trailing: Icon(
                    item.dungSai ? Icons.check_circle : Icons.cancel,
                    color: item.dungSai ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context), // Quay về Home
              child: const Text("Về trang chủ"),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}