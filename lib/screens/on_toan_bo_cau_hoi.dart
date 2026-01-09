
import '../models/cau_hoi.dart';
import 'package:flutter/material.dart';
import '../services/cau_hoi_service_api.dart';
class OnToanBoCauHoiScreen extends StatefulWidget {
  const OnToanBoCauHoiScreen({
    super.key
  });

  @override
  State<OnToanBoCauHoiScreen> createState() => _OnToanBoCauHoiScreenState();
}

class _OnToanBoCauHoiScreenState extends State<OnToanBoCauHoiScreen> {
  late Future<List<CauHoi>> _futureCauHois;
  // Lưu đáp án người dùng đã chọn cho từng câu hỏi {index: "A"}
  Map<int, String> _userSelections = {};

  @override
  void initState() {
    super.initState();
    _futureCauHois = ApiCauHoiService.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ôn tập các câu hỏi hay sai"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<CauHoi>>(
        future: _futureCauHois,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Không có câu hỏi nào."));
          }

          final cauHois = snapshot.data!;
          return PageView.builder(
            itemCount: cauHois.length,
            itemBuilder: (context, index) {
              return _buildQuestionItem(cauHois[index], index, cauHois.length);
            },
          );
        },
      ),
    );
  }

  Widget _buildQuestionItem(CauHoi cauHoi, int index, int total) {
    bool hasAnswered = _userSelections.containsKey(index);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            cauHoi.noiDung,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),

          // Danh sách đáp án
          _buildOption(cauHoi, index, "A", cauHoi.luaChonA),
          _buildOption(cauHoi, index, "B", cauHoi.luaChonB),
          if (cauHoi.luaChonC != null) _buildOption(cauHoi, index, "C", cauHoi.luaChonC!),
          if (cauHoi.luaChonD != null) _buildOption(cauHoi, index, "D", cauHoi.luaChonD!),

          const SizedBox(height: 20),

          // Phần hiển thị sau khi trả lời
          if (hasAnswered) ...[
            // Khối giải thích
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.05),
                border: Border(left: BorderSide(color: Colors.orange.shade700, width: 4)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text("Giải thích đáp án:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cauHoi.giaiThich ?? "Câu hỏi này không có giải thích cụ thể.",
                    style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Nút Làm lại thiết kế rõ ràng
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _userSelections.remove(index); // Xóa để cho phép chọn lại
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.replay),
                label: const Text("LÀM LẠI CÂU NÀY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 40), // Khoảng trống cuối trang
          ],
        ],
      ),
    );
  }

  Widget _buildOption(CauHoi cauHoi, int qIndex, String key, String text) {
    String? selected = _userSelections[qIndex];
    bool isSelected = selected == key;
    bool isCorrect = cauHoi.dapAnDung == key;
    bool hasAnswered = selected != null;

    // Logic màu sắc
    Color borderColor = Colors.grey.shade300;
    Color bgColor = Colors.white;
    Widget? trailingIcon;

    if (hasAnswered) {
      if (isCorrect) {
        borderColor = Colors.green;
        bgColor = Colors.green.shade50;
        trailingIcon = const Icon(Icons.check_circle, color: Colors.green);
      } else if (isSelected) {
        borderColor = Colors.red;
        bgColor = Colors.red.shade50;
        trailingIcon = const Icon(Icons.cancel, color: Colors.red);
      }
    }

    return GestureDetector(
      onTap: hasAnswered ? null : () {
        setState(() {
          _userSelections[qIndex] = key;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: isSelected || (hasAnswered && isCorrect) ? 2 : 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: isSelected || (hasAnswered && isCorrect) ? borderColor : Colors.grey.shade200,
              child: Text(key, style: TextStyle(color: isSelected || (hasAnswered && isCorrect) ? Colors.white : Colors.black)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected || (hasAnswered && isCorrect) ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (trailingIcon != null) trailingIcon,
          ],
        ),
      ),
    );
  }
}