import 'package:flutter/material.dart';
import '../models/bai_thi.dart';
import '../models/cau_hoi.dart';
import '../services/bai_thi_api.dart';
import 'ket_qua_bai_thi_screen.dart';

class LamBaiThiScreen extends StatefulWidget {
  final String baiThiId;
  const LamBaiThiScreen({super.key, required this.baiThiId});

  @override
  State<LamBaiThiScreen> createState() => _LamBaiThiScreenState();
}

class _LamBaiThiScreenState extends State<LamBaiThiScreen> {
  late Future<BaiThi> _baiThiFuture;
  late PageController _pageController; // Thêm controller để nhảy câu hỏi
  int _currentQuestionIndex = 0;
  Map<int, String> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _baiThiFuture = ApiBaiThiService.getById(widget.baiThiId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Hàm để nhảy tới câu hỏi bất kỳ
  void _goToQuestion(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Làm bài thi'),
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          // Nút mở danh sách câu hỏi nhanh trên AppBar
          IconButton(
            icon: const Icon(Icons.grid_view),
            onPressed: () => _showQuestionSheet(context),
          )
        ],
      ),
      body: FutureBuilder<BaiThi>(
        future: _baiThiFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Lỗi: ${snapshot.error}'));

          final baiThi = snapshot.data!;
          final questions = baiThi.chiTietBaiThis;

          return Column(
            children: [
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / questions.length,
                color: Colors.green,
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentQuestionIndex = index),
                  itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final chiTiet = questions[index];

                      // Kiểm tra nếu dữ liệu câu hỏi bị rỗng (null) từ API
                      if (chiTiet.cauHoi == null) {
                        return const Center(child: Text("Câu hỏi này chưa có dữ liệu nội dung."));
                      }
                      // Dùng dấu ! để báo với Flutter rằng chiTiet.cauHoi chắc chắn không null ở dòng này
                      return _buildQuestionCard(chiTiet.cauHoi!, index);
                    }
                ),
              ),
              _buildBottomAction(questions),
            ],
          );
        },
      ),
    );
  }
  void _submitExam(List<ChiTietBaiThi> questions) async {
    // 1. Kiểm tra xem người dùng đã làm hết bài chưa
    int totalQuestions = questions.length;
    int answeredQuestions = _selectedAnswers.length;

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận nộp bài'),
        content: Text('Bạn đã hoàn thành $answeredQuestions/$totalQuestions câu hỏi. Bạn có chắc chắn muốn kết thúc bài thi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tiếp tục làm')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Nộp bài', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 2. Hiển thị Loading trong khi chờ Server xử lý
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator())
    );

    try {
      // 3. Định dạng lại dữ liệu Answers theo yêu cầu của Backend (Dictionary<Guid, string>)
      // Key phải là Id của ChiTietBaiThi
      Map<String, String> formattedAnswers = {};
      _selectedAnswers.forEach((index, value) {
        String chiTietId = questions[index].id;
        formattedAnswers[chiTietId] = value;
      });

      // 4. Gọi Service để gửi dữ liệu
      final resultData = await ApiBaiThiService.submitResult(widget.baiThiId, formattedAnswers);
      print("--- DỮ LIỆU TỪ SERVER ---");
      print(resultData);
      print("-------------------------");
      // Tắt dialog loading
      if (mounted) Navigator.pop(context);

      // 5. Chuyển đổi dữ liệu JSON trả về thành Model Kết Quả
      final ketQuaModel = KetQuaNopBai.fromJson(resultData);

      // 6. Chuyển sang màn hình kết quả (Xóa màn hình làm bài khỏi stack)
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => KetQuaBaiThiScreen(ketQua: ketQuaModel)),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Tắt loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi nộp bài: $e'), backgroundColor: Colors.red),
      );
    }
  }
  // Lưới danh sách câu hỏi (BottomSheet)
  void _showQuestionSheet(BuildContext context) {
    _baiThiFuture.then((baiThi) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Danh sách câu hỏi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5, // 5 cột
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: baiThi.chiTietBaiThis.length,
                    itemBuilder: (context, index) {
                      bool isAnswered = _selectedAnswers.containsKey(index);
                      bool isCurrent = _currentQuestionIndex == index;

                      return GestureDetector(
                        onTap: () {
                          _goToQuestion(index);
                          Navigator.pop(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            // Nếu làm rồi thì màu xanh, chưa làm màu xám nhạt
                            color: isAnswered ? Colors.green : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: isCurrent ? Border.all(color: Colors.orange, width: 3) : null,
                          ),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isAnswered ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildQuestionCard(CauHoi cauHoi, int index) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Câu hỏi ${index + 1}:', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(cauHoi.noiDung, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildOption(index, 'A', cauHoi.luaChonA),
          _buildOption(index, 'B', cauHoi.luaChonB),
          _buildOption(index, 'C', cauHoi.luaChonC),
          _buildOption(index, 'D', cauHoi.luaChonD),
        ],
      ),
    );
  }

  Widget _buildOption(int questionIndex, String key, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    bool isSelected = _selectedAnswers[questionIndex] == key;

    return GestureDetector(
      onTap: () => setState(() => _selectedAnswers[questionIndex] = key),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.green : Colors.grey[300]!, width: 2),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: isSelected ? Colors.green : Colors.grey[300],
              child: Text(key, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 14)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction(List<ChiTietBaiThi> questions) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Row(
        children: [
          // Nút mở Grid câu hỏi nhanh ở dưới
          IconButton(
            onPressed: () => _showQuestionSheet(context),
            icon: const Icon(Icons.apps, color: Colors.deepPurple),
          ),
          const SizedBox(width: 10),
          Text('${_selectedAnswers.length}/${questions.length} câu', style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => _submitExam(questions), // GỌI HÀM NỘP BÀI TẠI ĐÂY
            child: const Text('Nộp bài', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}