import 'package:flutter/material.dart';
import '../models/cau_hoi.dart';
import '../models/chu_de.dart';
import '../models/loai_bang_lai.dart';
import '../services/cau_hoi_service_api.dart';
import '../services/chu_de_service_api.dart';
import '../services/loai_bang_lai_api.dart';

class OnTapTheoChuDeScreen extends StatefulWidget {
  const OnTapTheoChuDeScreen({super.key});

  @override
  State<OnTapTheoChuDeScreen> createState() => _OnTapTheoChuDeScreenState();
}

class _OnTapTheoChuDeScreenState extends State<OnTapTheoChuDeScreen> {
  late Future<List<LoaiBangLai>> _loaiBangLaiFuture;
  late Future<List<ChuDe>> _chuDeFuture;
  String? _selectedLoaiBangLaiId;

  // Định nghĩa base URL để nối link ảnh local
  final String serverUrl = 'http://10.0.2.2:5084';

  @override
  void initState() {
    super.initState();
    _chuDeFuture = ApiChuDeService.getAll();
    _loaiBangLaiFuture = ApiLoaiBangLaiService.getAll();

    // Mặc định chọn ID đầu tiên ngay khi tải trang
    _loaiBangLaiFuture.then((list) {
      if (list.isNotEmpty && mounted) {
        setState(() {
          _selectedLoaiBangLaiId = list[0].id;
        });
      }
    });
  }
  void _navigateToOnTapDetail(ChuDe chuDe) {
    if (_selectedLoaiBangLaiId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CauHoiOnTapScreen(
            loaiBangLaiId: _selectedLoaiBangLaiId!,
            chuDeId: chuDe.id,
            tenChuDe: chuDe.tenChuDe,
          ),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildFilterHeader(),
          Expanded(child: _buildTopicGrid()),
        ],
      ),
    );
  }

  // Dropdown lọc hạng xe
  Widget _buildFilterHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      child: FutureBuilder<List<LoaiBangLai>>(
        future: _loaiBangLaiFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LinearProgressIndicator();

          return DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Hạng xe ôn tập",
              prefixIcon: const Icon(Icons.drive_eta, color: Colors.indigo),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            value: _selectedLoaiBangLaiId,
            items: snapshot.data!.map((loai) {
              return DropdownMenuItem(value: loai.id, child: Text("Hạng ${loai.tenLoai}"));
            }).toList(),
            onChanged: (val) => setState(() => _selectedLoaiBangLaiId = val),
          );
        },
      ),
    );
  }

  // Danh sách Grid vuông
  Widget _buildTopicGrid() {
    return FutureBuilder<List<ChuDe>>(
      future: _chuDeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return Center(child: Text("Lỗi: ${snapshot.error}"));

        final topics = snapshot.data ?? [];
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 cột vuông
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: topics.length,
          itemBuilder: (context, index) => _buildSquareCard(topics[index]),
        );
      },
    );
  }

  Widget _buildSquareCard(ChuDe chuDe) {
    // Xử lý link ảnh local
    // Nếu imageUrl đã có http thì giữ nguyên, nếu không thì nối thêm serverUrl
    final String imageUrl = (chuDe.imageUrl != null && chuDe.imageUrl!.isNotEmpty)
        ? (chuDe.imageUrl!.startsWith('http') ? chuDe.imageUrl! : '$serverUrl${chuDe.imageUrl}')
        : '';

    return InkWell(
      onTap: () {
        _navigateToOnTapDetail(chuDe);
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 3,
        child: Column(
          children: [
            // Ảnh minh họa chiếm phần lớn card
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                )
                    : const Icon(Icons.image, size: 50, color: Colors.indigo),
              ),
            ),
            // Tên chủ đề nằm dưới
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  chuDe.tenChuDe,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CauHoiOnTapScreen extends StatefulWidget {
  final String loaiBangLaiId;
  final String chuDeId;
  final String tenChuDe;

  const CauHoiOnTapScreen({
    super.key,
    required this.loaiBangLaiId,
    required this.chuDeId,
    required this.tenChuDe,
  });

  @override
  State<CauHoiOnTapScreen> createState() => _CauHoiOnTapScreenState();
}

class _CauHoiOnTapScreenState extends State<CauHoiOnTapScreen> {
  late Future<List<CauHoi>> _futureCauHois;
  // Lưu đáp án người dùng đã chọn cho từng câu hỏi {index: "A"}
  Map<int, String> _userSelections = {};

  @override
  void initState() {
    super.initState();
    _futureCauHois = ApiCauHoiService.getCauHoiOnTap(widget.loaiBangLaiId, widget.chuDeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tenChuDe),
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
          // Thanh trạng thái câu hỏi
          Text(
            "Câu hỏi ${index + 1}/$total",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
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