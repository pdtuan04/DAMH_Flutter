import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lich_su_thi.dart';
import '../services/authenticate.dart';

class LichSuThiScreen extends StatefulWidget {
  const LichSuThiScreen({super.key});

  @override
  State<LichSuThiScreen> createState() => _LichSuThiScreenState();
}

class _LichSuThiScreenState extends State<LichSuThiScreen> {
  List<LichSuThi> _lichSuList = [];
  LichSuThiStats? _stats;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  
  int _currentPage = 1;
  int _totalPages = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Load lịch sử thi và stats song song
      final results = await Future.wait([
        Authenticate.getLichSuThi(pageNumber: _currentPage, pageSize: _pageSize),
        Authenticate.getLichSuThiStats(),
      ]);

      final lichSuData = results[0] as Map<String, dynamic>;
      final stats = results[1] as LichSuThiStats;

      setState(() {
        _lichSuList = lichSuData['items'];
        _totalPages = lichSuData['totalPages'];
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    _currentPage = 1;
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text('Lịch Sử Thi', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refresh,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : _hasError
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: CustomScrollView(
                    slivers: [
                      // Stats Card
                      if (_stats != null && _stats!.tongSoBaiThi > 0)
                        SliverToBoxAdapter(
                          child: _buildStatsCard(),
                        ),
                      
                      // List header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            'Lịch sử các bài thi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),

                      // List
                      _lichSuList.isEmpty
                          ? SliverFillRemaining(child: _buildEmptyState())
                          : SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildLichSuCard(_lichSuList[index]),
                                  childCount: _lichSuList.length,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatsCard() {
  return Container(
    margin: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF1976D2), Color(0xFF42A5F5)], // Đổi sang xanh dương
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.4), // Đổi shadow sang màu xanh dương
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Stack(
      children: [
        // Decorative circles
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        Positioned(
          bottom: -20,
          left: -20,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        
        // Content
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.analytics_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Thống kê',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Main stats - Chỉ hiển thị 3 thống kê (bỏ Điểm TB)
              Row(
                children: [
                  Expanded(
                    child: _buildModernStatCard(
                      'Tổng số bài',
                      _stats!.tongSoBaiThi.toString(),
                      Icons.article_outlined,
                      Colors.white,
                      true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModernStatCard(
                      'Đạt',
                      _stats!.soBaiThiDat.toString(),
                      Icons.check_circle_rounded,
                      Colors.greenAccent,
                      false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModernStatCard(
                      'Không đạt',
                      _stats!.soBaiThiKhongDat.toString(),
                      Icons.cancel_rounded,
                      Colors.redAccent,
                      false,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Progress bar for success rate
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tỷ lệ đúng',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${_stats!.tyLeDung.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _stats!.tyLeDung / 100,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      color: Colors.greenAccent,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildModernStatCard(
  String label,
  String value,
  IconData icon,
  Color iconColor,
  bool isHighlight,
) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isHighlight 
          ? Colors.white.withOpacity(0.25)
          : Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.white.withOpacity(0.3),
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildLichSuCard(LichSuThi lichSu) {
    final isDat = lichSu.isDat;
    final color = isDat ? Colors.green : Colors.red;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showDetailDialog(lichSu),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lichSu.tenBaiThi,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDat ? Icons.check_circle : Icons.cancel,
                            size: 14,
                            color: color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            lichSu.ketQua,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Progress - Tính phần trăm dựa trên số câu đúng/tổng số câu
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: lichSu.tongSoCau > 0 
                        ? lichSu.soCauDung / lichSu.tongSoCau 
                        : 0,
                    backgroundColor: Colors.grey.shade200,
                    color: color,
                    minHeight: 6,
                  ),
                ),
                
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.check_circle_outline,
                      '${lichSu.soCauDung}/${lichSu.tongSoCau}',
                      Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.grade_rounded,
                      '${lichSu.diem} điểm',
                      Colors.orange,
                    ),
                    if (lichSu.macLoiNghiemTrong) ...[
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.warning_rounded,
                        'Lỗi nghiêm trọng',
                        Colors.red,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(lichSu.ngayThi),
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(LichSuThi lichSu) async {
  try {
    // Show loading dialog first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.indigo),
        ),
      ),
    );

    // Fetch detailed data
    final detail = await Authenticate.getChiTietLichSuThi(lichSu.id);
    
    // Close loading dialog - QUAN TRỌNG: Phải đóng trước khi làm gì khác
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    // Đợi một chút để đảm bảo dialog đã đóng
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    if (detail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể tải chi tiết bài thi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show detail dialog
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: lichSu.isDat 
                        ? [Colors.green.shade400, Colors.green.shade600]
                        : [Colors.red.shade400, Colors.red.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      lichSu.isDat ? Icons.check_circle : Icons.cancel,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Chi tiết kết quả',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            lichSu.ketQua,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Summary Stats
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade50,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickStat(
                        'Số câu đúng',
                        '${lichSu.soCauDung}',
                        Icons.check_circle_outline,
                        Colors.green,
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.grey.shade300),
                    Expanded(
                      child: _buildQuickStat(
                        'Số câu sai',
                        '${lichSu.tongSoCau - lichSu.soCauDung}',
                        Icons.cancel_outlined,
                        Colors.red,
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.grey.shade300),
                    Expanded(
                      child: _buildQuickStat(
                        'Điểm',
                        '${lichSu.diem}',
                        Icons.grade,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Question List
              Expanded(
                child: detail.chiTietList.isEmpty
                    ? const Center(child: Text('Không có dữ liệu chi tiết'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: detail.chiTietList.length,
                        itemBuilder: (context, index) {
                          final item = detail.chiTietList[index];
                          return _buildQuestionDetailCard(item, index + 1);
                        },
                      ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(lichSu.ngayThi),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } catch (e, stackTrace) {
    print('❌ Error in _showDetailDialog: $e');
    print('Stack: $stackTrace');
    
    // Đảm bảo đóng loading dialog nếu có lỗi
    if (mounted) {
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (_) {}
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

Widget _buildQuickStat(String label, String value, IconData icon, Color color) {
  return Column(
    children: [
      Icon(icon, color: color, size: 24),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade600,
        ),
      ),
    ],
  );
}

Widget _buildQuestionDetailCard(ChiTietLichSuThi item, int index) {
  final isCorrect = item.dungSai;
  final color = isCorrect ? Colors.green : Colors.red;
  
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: color.withOpacity(0.3),
        width: 1.5,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question number and status
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Câu $index',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (item.diemLiet) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, size: 12, color: Colors.red),
                    SizedBox(width: 4),
                    Text(
                      'Điểm liệt',
                      style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Question content
        Text(
          item.noiDung,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Answers
        _buildAnswerOption('A', item.luaChonA, item.dapAnDung, item.cauTraLoi),
        _buildAnswerOption('B', item.luaChonB, item.dapAnDung, item.cauTraLoi),
        _buildAnswerOption('C', item.luaChonC, item.dapAnDung, item.cauTraLoi),
        _buildAnswerOption('D', item.luaChonD, item.dapAnDung, item.cauTraLoi),
        
        // Result summary
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(
                'Bạn chọn: ',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              Text(
                item.cauTraLoi ?? 'Không chọn',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Đáp án đúng: ',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              Text(
                item.dapAnDung,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildAnswerOption(String prefix, String content, String correctAnswer, String? userAnswer) {
  final isCorrect = prefix == correctAnswer;
  final isUserChoice = prefix == userAnswer;
  
  Color bgColor = Colors.transparent;
  Color textColor = Colors.black87;
  
  if (isCorrect) {
    bgColor = Colors.green.shade50;
    textColor = Colors.green.shade700;
  } else if (isUserChoice && !isCorrect) {
    bgColor = Colors.red.shade50;
    textColor = Colors.red.shade700;
  }
  
  return Container(
    margin: const EdgeInsets.only(bottom: 4),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: isCorrect 
            ? Colors.green.shade200
            : (isUserChoice ? Colors.red.shade200 : Colors.grey.shade200),
        width: 1,
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isCorrect 
                ? Colors.green 
                : (isUserChoice ? Colors.red : Colors.grey.shade300),
            shape: BoxShape.circle,
          ),
          child: Text(
            prefix,
            style: TextStyle(
              color: (isCorrect || isUserChoice) ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight: (isCorrect || isUserChoice) ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        if (isCorrect)
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
        if (isUserChoice && !isCorrect)
          const Icon(Icons.cancel, color: Colors.red, size: 18),
      ],
    ),
  );
}


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Chưa có lịch sử thi',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy bắt đầu làm bài thi đầu tiên của bạn!',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          const Text('Không thể tải lịch sử thi'),
          const SizedBox(height: 8),
          Text(_errorMessage, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
          ),
        ],
      ),
    );
  }
}