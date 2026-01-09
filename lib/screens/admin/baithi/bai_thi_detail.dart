import 'package:flutter/material.dart';
import '../../../models/bai_thi.dart';
import '../../../models/chu_de.dart';
import '../../../models/cau_hoi.dart'; // Added import
import '../../../services/bai_thi_api.dart';
import '../../../services/chu_de_service_api.dart';
import '../../../services/cau_hoi_service_api.dart';

class BaiThiDetail extends StatefulWidget {
  final BaiThi baiThi;

  const BaiThiDetail({Key? key, required this.baiThi}) : super(key: key);

  @override
  _BaiThiDetailState createState() => _BaiThiDetailState();
}

class _BaiThiDetailState extends State<BaiThiDetail> {
  bool _isLoading = true;
  BaiThi? _fullItem;
  List<ChuDe> _chuDes = [];
  String? _error;
  Map<String, CauHoi> _fullQuestionsMap = {};

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final results = await Future.wait([
        ApiBaiThiService.getById(widget.baiThi.id),
        ApiChuDeService.getAll(),
        ApiCauHoiService.getPagedCauHoi(1, 10000), // Fetch all questions to ensure we have full details like chuDeId
      ]);

      if (mounted) {
        setState(() {
          _fullItem = results[0] as BaiThi;
          _chuDes = results[1] as List<ChuDe>;
          
          final allQuestions = (results[2] as Map<String, dynamic>)['items'] as List<CauHoi>;
          _fullQuestionsMap = {for (var q in allQuestions) q.id: q};
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _getTenChuDe(String? chuDeId) {
    if (chuDeId == null) return 'N/A';
    final found = _chuDes.firstWhere(
      (element) => element.id == chuDeId,
      orElse: () => ChuDe(id: '', tenChuDe: 'N/A', moTa: ''),
    );
    return found.tenChuDe;
  }

  CauHoi _getFullQuestion(CauHoi partialQuestion) {
    return _fullQuestionsMap[partialQuestion.id] ?? partialQuestion;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.baiThi.tenBaiThi),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Lỗi: $_error', style: const TextStyle(color: Colors.red)))
              : _fullItem == null
                  ? const Center(child: Text('Không tìm thấy dữ liệu'))
                  : Column(
                      children: [
                        Expanded(child: _buildList()),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Quay lại danh sách'),
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildList() {
    final data = _fullItem!.chiTietBaiThis;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final ct = data[index];
        var cauHoi = ct.cauHoi;

        if (cauHoi == null) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: const Text('Câu hỏi đã bị xóa', style: TextStyle(color: Colors.red)),
            ),
          );
        }

        // Use full details from the map to ensure we have chuDeId and diemLiet
        cauHoi = _getFullQuestion(cauHoi);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.blue.shade100,
                      child: Text('${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cauHoi.noiDung,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                
                // Topic
                Row(
                  children: [
                    const Icon(Icons.topic_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text('Chủ đề: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    Expanded(child: Text(_getTenChuDe(cauHoi.chuDeId), style: const TextStyle(color: Colors.grey))),
                  ],
                ),
                const SizedBox(height: 8),

                // Answer and Paralysis
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: [
                              const TextSpan(text: 'Đáp án: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: cauHoi.dapAnDung, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (cauHoi.diemLiet)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red),
                        ),
                        child: const Text('Điểm liệt', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    else 
                       Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Text('Không liệt', style: TextStyle(color: Colors.green, fontSize: 12)),
                      )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
