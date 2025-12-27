import 'package:flutter/material.dart';
import 'dart:async';
import '../models/bai_thi.dart';
import '../models/cau_hoi.dart';
import '../services/bai_thi_api.dart';
import 'ket_qua_bai_thi_screen.dart';

class LamBaiThiNgauNhienScreen extends StatefulWidget {
  const LamBaiThiNgauNhienScreen({super.key});

  @override
  State<LamBaiThiNgauNhienScreen> createState() => _LamBaiThiNgauNhienScreenState();
}

class _LamBaiThiNgauNhienScreenState extends State<LamBaiThiNgauNhienScreen> {
  late Future<BaiThi> _baiThiFuture;
  late PageController _pageController;
  late BaiThi baiThi;

  int _currentQuestionIndex = 0;
  Map<int, String> _selectedAnswers = {};

  Timer? _timer;
  int _remainingSeconds = 1140; // 19 phút
  bool _isTimerStarted = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _baiThiFuture = ApiBaiThiService.getRandom();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer(int minutes) {
    if (_isTimerStarted) return;
    setState(() {
      _remainingSeconds = minutes * 60;
      _isTimerStarted = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        _handleTimeUp();
      }
    });
  }

  void _handleTimeUp() {
    _submitExam(baiThi.chiTietBaiThis, isForced: true);
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Làm Bài Thi', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<BaiThi>(
        future: _baiThiFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Center(child: Text('Lỗi: ${snapshot.error}'));

          baiThi = snapshot.data!;
          final questions = baiThi.chiTietBaiThis;

          if (!_isTimerStarted) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _startTimer(19));
          }

          // --- LOGIC MỚI: Tính tiến độ dựa trên số câu đã chọn đáp án ---
          double progress = questions.isNotEmpty ? _selectedAnswers.length / questions.length : 0;

          return Column(
            children: [
              _buildTimerHeader(progress, questions.length),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentQuestionIndex = index),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final chiTiet = questions[index];
                    if (chiTiet.cauHoi == null) return const Center(child: Text("Câu hỏi trống"));
                    return _buildQuestionCard(chiTiet.cauHoi!, index);
                  },
                ),
              ),
              _buildBottomAction(questions),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimerHeader(double progress, int total) {
    bool isWarning = _isTimerStarted && _remainingSeconds < 120;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isWarning ? Colors.redAccent : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text(
              _formatTime(_remainingSeconds),
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hiển thị số câu đã làm thay vì phần trăm dựa trên vị trí trang
                Text(
                  'Tiến độ: ${_selectedAnswers.length}/$total câu',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitExam(List<ChiTietBaiThi> questions, {bool isForced = false}) async {
    if (!isForced) {
      bool? confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Nộp bài?'),
          content: Text('Bạn đã làm ${_selectedAnswers.length}/${questions.length} câu. Bạn có chắc chắn muốn nộp?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    _timer?.cancel();
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    try {
      Map<String, String> formattedAnswers = {};
      _selectedAnswers.forEach((index, value) {
        formattedAnswers[questions[index].id] = value;
      });

      final resultData = await ApiBaiThiService.submitResult(baiThi.id, formattedAnswers);
      if (mounted) Navigator.pop(context);

      final ketQuaModel = KetQuaNopBai.fromJson(resultData);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => KetQuaBaiThiScreen(ketQua: ketQuaModel)),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  void _showQuestionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Column(
          children: [
            const Text('Danh sách câu hỏi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: baiThi.chiTietBaiThis.length,
                itemBuilder: (context, index) {
                  bool done = _selectedAnswers.containsKey(index);
                  bool current = _currentQuestionIndex == index;
                  return InkWell(
                    onTap: () { Navigator.pop(context); _goToQuestion(index); },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: done ? Colors.green : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        border: current ? Border.all(color: Colors.orange, width: 3) : null,
                      ),
                      child: Text('${index + 1}', style: TextStyle(color: done ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(CauHoi cauHoi, int index) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CÂU HỎI ${index + 1}', style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(cauHoi.noiDung, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.4)),
              if (cauHoi.diemLiet)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('(*) Câu hỏi điểm liệt', style: TextStyle(color: Colors.red[700], fontStyle: FontStyle.italic)),
                ),
              const SizedBox(height: 24),
              _buildOption(index, 'A', cauHoi.luaChonA),
              _buildOption(index, 'B', cauHoi.luaChonB),
              _buildOption(index, 'C', cauHoi.luaChonC),
              _buildOption(index, 'D', cauHoi.luaChonD),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(int questionIndex, String key, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    bool selected = _selectedAnswers[questionIndex] == key;

    return InkWell(
      onTap: () => setState(() => _selectedAnswers[questionIndex] = key),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? Colors.indigo.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Colors.indigo : Colors.grey[300]!, width: 1.5),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: selected ? Colors.indigo : Colors.grey[200],
              child: Text(key, style: TextStyle(fontSize: 12, color: selected ? Colors.white : Colors.black87)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(onPressed: () => _showQuestionSheet(context), icon: const Icon(Icons.apps, color: Colors.indigo)),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _submitExam(questions),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('NỘP BÀI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}