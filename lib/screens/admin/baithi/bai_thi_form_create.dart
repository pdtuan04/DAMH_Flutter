import 'package:flutter/material.dart';
import '../../../models/loai_bang_lai.dart';
import '../../../models/chu_de.dart';
import '../../../models/cau_hoi.dart';
import '../../../services/loai_bang_lai_api.dart';
import '../../../services/chu_de_service_api.dart';
import '../../../services/cau_hoi_service_api.dart';
import '../../../services/bai_thi_api.dart';

class BaiThiFormCreate extends StatefulWidget {
  const BaiThiFormCreate({Key? key}) : super(key: key);

  @override
  _BaiThiFormCreateState createState() => _BaiThiFormCreateState();
}

class _BaiThiFormCreateState extends State<BaiThiFormCreate> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  List<LoaiBangLai> _loaiBangLais = [];
  List<ChuDe> _chuDes = [];
  List<CauHoi> _questions = [];

  String? _selectedLoaiBangLaiId;
  String? _selectedChuDeId;
  final Set<String> _selectedQuestionIds = {};

  bool _isLoading = false;
  bool _isLoadingQuestions = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final lbls = await ApiLoaiBangLaiService.getAll();
      if (mounted) {
        setState(() {
          _loaiBangLais = lbls;
          if (lbls.isNotEmpty) _selectedLoaiBangLaiId = lbls.first.id;
        });
        if (_selectedLoaiBangLaiId != null) {
          _loadChuDe(_selectedLoaiBangLaiId!);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadChuDe(String loaiBangLaiId) async {
    try {
      final cds = await ApiChuDeService.getAll();
      setState(() => _chuDes = cds);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadQuestions() async {
    if (_selectedLoaiBangLaiId == null || _selectedChuDeId == null) return;

    setState(() => _isLoadingQuestions = true);
    try {
      final qs = await ApiCauHoiService.getCauHoiOnTap(_selectedLoaiBangLaiId!, _selectedChuDeId!);
      setState(() {
        _questions = qs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải câu hỏi: $e')));
    } finally {
      setState(() => _isLoadingQuestions = false);
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedQuestionIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chưa chọn câu hỏi nào')));
        return;
      }

      setState(() => _isLoading = true);
      try {
        await ApiBaiThiService.create(
          _nameController.text,
          _selectedQuestionIds.toList(),
        );
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tạo đề thi thành công')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm Đề Thi Mới')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Tên Đề Thi', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Nhập tên đề thi' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _selectedLoaiBangLaiId,
                          decoration: const InputDecoration(labelText: 'Loại Bằng', border: OutlineInputBorder()),
                          items: _loaiBangLais.map((e) => DropdownMenuItem(value: e.id, child: Text(e.tenLoai, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (v) {
                            setState(() {
                              _selectedLoaiBangLaiId = v;
                              _questions = [];
                              _selectedQuestionIds.clear();
                            });
                            if (v != null && _chuDes.isNotEmpty) { // Trigger load if Chude is selected? No, wait for user to select Chude
                               // Assuming User must select Chude manually or it stays previous
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _selectedChuDeId,
                          decoration: const InputDecoration(labelText: 'Chủ Đề', border: OutlineInputBorder()),
                          items: _chuDes.map((e) => DropdownMenuItem(value: e.id, child: Text(e.tenChuDe, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (v) {
                            setState(() => _selectedChuDeId = v);
                            _loadQuestions();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          if (_isLoadingQuestions) const LinearProgressIndicator(),
          if (_questions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Danh sách câu hỏi (${_questions.length})'),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (_selectedQuestionIds.length == _questions.length) {
                          _selectedQuestionIds.clear();
                        } else {
                          _selectedQuestionIds.addAll(_questions.map((e) => e.id));
                        }
                      });
                    },
                    child: Text(_selectedQuestionIds.length == _questions.length ? 'Bỏ chọn tất cả' : 'Chọn tất cả'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _questions.length,
              itemBuilder: (ctx, index) {
                final item = _questions[index];
                final isSelected = _selectedQuestionIds.contains(item.id);
                return CheckboxListTile(
                  value: isSelected,
                  title: Text(item.noiDung, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text('ID: ${item.id.substring(0,8)}...'),
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selectedQuestionIds.add(item.id);
                      } else {
                        _selectedQuestionIds.remove(item.id);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: _isLoading ? null : _submit,
              child: Text(_isLoading ? 'Đang xử lý...' : 'TẠO ĐỀ THI (${_selectedQuestionIds.length} câu)'),
            ),
          ),
        ],
      ),
    );
  }
}
