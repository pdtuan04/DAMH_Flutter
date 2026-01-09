import 'package:flutter/material.dart';
import '../../../models/cau_hoi.dart';
import '../../../services/loai_bang_lai_api.dart';
import '../../../services/chu_de_service_api.dart';

class CauHoiDetail extends StatefulWidget {
  final CauHoi cauHoi;

  const CauHoiDetail({Key? key, required this.cauHoi}) : super(key: key);

  @override
  _CauHoiDetailState createState() => _CauHoiDetailState();
}

class _CauHoiDetailState extends State<CauHoiDetail> {
  String _loaiBangLaiName = 'Đang tải...';
  String _chuDeName = 'Đang tải...';

  @override
  void initState() {
    super.initState();
    _loadNames();
  }

  Future<void> _loadNames() async {
    try {

      if (widget.cauHoi.loaiBangLaiId != null) {
         final lbls = await ApiLoaiBangLaiService.getAll();
         final found = lbls.firstWhere((e) => e.id == widget.cauHoi.loaiBangLaiId, orElse: () => lbls.first); 
         // simplistic fallback or handle not found
         if (mounted) setState(() => _loaiBangLaiName = found.tenLoai);
      } else {
         if (mounted) setState(() => _loaiBangLaiName = 'Không có');
      }

      if (widget.cauHoi.chuDeId != null) {
        final cds = await ApiChuDeService.getAll();
        final found = cds.firstWhere((e) => e.id == widget.cauHoi.chuDeId, orElse: () => cds.first);
        if (mounted) setState(() => _chuDeName = found.tenChuDe);
      } else {
         if (mounted) setState(() => _chuDeName = 'Không có');
      }

    } catch (e) {
      if (mounted) setState(() {
        _loaiBangLaiName = 'Lỗi tải';
        _chuDeName = 'Lỗi tải';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.cauHoi;
    return Scaffold(
      appBar: AppBar(title: const Text('Chi Tiết Câu Hỏi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Nội dung:', item.noiDung),
            const Divider(),
            _buildDetailRow('Loại Bằng:', _loaiBangLaiName),
            _buildDetailRow('Chủ Đề:', _chuDeName),
            const Divider(),
            Text('Đáp án đúng:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildOption('A', item.luaChonA, item.dapAnDung == 'A'),
            _buildOption('B', item.luaChonB, item.dapAnDung == 'B'),
            if (item.luaChonC != null && item.luaChonC!.isNotEmpty) _buildOption('C', item.luaChonC!, item.dapAnDung == 'C'),
            if (item.luaChonD != null && item.luaChonD!.isNotEmpty) _buildOption('D', item.luaChonD!, item.dapAnDung == 'D'),
            const Divider(),
            _buildDetailRow('Giải thích:', item.giaiThich ?? 'Không có'),
            _buildDetailRow('Điểm liệt:', item.diemLiet ? 'Có' : 'Không', color: item.diemLiet ? Colors.red : Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value, style: TextStyle(color: color))),
        ],
      ),
    );
  }

  Widget _buildOption(String label, String content, bool isCorrect) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
        border: Border.all(color: isCorrect ? Colors.green : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: isCorrect ? Colors.green : Colors.grey,
            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(content, style: TextStyle(fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal))),
          if (isCorrect) const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }
}
