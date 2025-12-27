import 'package:flutter/material.dart';
import '../../../models/cau_hoi.dart';
import '../../../models/loai_bang_lai.dart';
import '../../../models/chu_de.dart';
import '../../../services/cau_hoi_service_api.dart';
import '../../../services/loai_bang_lai_api.dart';
import '../../../services/chu_de_service_api.dart';

class CauHoiFormCreate extends StatefulWidget {
  final CauHoi? cauHoi; 

  const CauHoiFormCreate({Key? key, this.cauHoi}) : super(key: key);

  @override
  _CauHoiFormCreateState createState() => _CauHoiFormCreateState();
}

class _CauHoiFormCreateState extends State<CauHoiFormCreate> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _noiDungController;
  late TextEditingController _luaChonAController;
  late TextEditingController _luaChonBController;
  late TextEditingController _luaChonCController;
  late TextEditingController _luaChonDController;
  late TextEditingController _giaiThichController;
  late TextEditingController _mediaUrlController; // Added

  String _dapAnDung = 'A';
  bool _diemLiet = false;
  String? _selectedLoaiBangLaiId;
  String? _selectedChuDeId;

  List<LoaiBangLai> _loaiBangLais = [];
  List<ChuDe> _chuDes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _noiDungController = TextEditingController(text: widget.cauHoi?.noiDung ?? '');
    _luaChonAController = TextEditingController(text: widget.cauHoi?.luaChonA ?? '');
    _luaChonBController = TextEditingController(text: widget.cauHoi?.luaChonB ?? '');
    _luaChonCController = TextEditingController(text: widget.cauHoi?.luaChonC ?? '');
    _luaChonDController = TextEditingController(text: widget.cauHoi?.luaChonD ?? '');
    _giaiThichController = TextEditingController(text: widget.cauHoi?.giaiThich ?? '');
    _mediaUrlController = TextEditingController(text: widget.cauHoi?.mediaUrl ?? ''); // Added

    // Listen for changes to update preview
    _mediaUrlController.addListener(() {
      setState(() {});
    });

    _dapAnDung = widget.cauHoi?.dapAnDung ?? 'A';
    _diemLiet = widget.cauHoi?.diemLiet ?? false;
    _selectedLoaiBangLaiId = widget.cauHoi?.loaiBangLaiId;
    _selectedChuDeId = widget.cauHoi?.chuDeId;

    _loadData();
  }

  @override
  void dispose() {
    _noiDungController.dispose();
    _luaChonAController.dispose();
    _luaChonBController.dispose();
    _luaChonCController.dispose();
    _luaChonDController.dispose();
    _giaiThichController.dispose();
    _mediaUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final lbls = await ApiLoaiBangLaiService.getAll();
      final cds = await ApiChuDeService.getAll();
      if (mounted) {
        setState(() {
          _loaiBangLais = lbls;
          _chuDes = cds;
          if (widget.cauHoi == null) {
            if (_loaiBangLais.isNotEmpty && _selectedLoaiBangLaiId == null) _selectedLoaiBangLaiId = _loaiBangLais.first.id;
            if (_chuDes.isNotEmpty && _selectedChuDeId == null) _selectedChuDeId = _chuDes.first.id;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final newCauHoi = CauHoi(
          id: widget.cauHoi?.id ?? '', 
          noiDung: _noiDungController.text,
          luaChonA: _luaChonAController.text,
          luaChonB: _luaChonBController.text,
          luaChonC: _luaChonCController.text.isNotEmpty ? _luaChonCController.text : null,
          luaChonD: _luaChonDController.text.isNotEmpty ? _luaChonDController.text : null,
          dapAnDung: _dapAnDung,
          giaiThich: _giaiThichController.text,
          diemLiet: _diemLiet,
          mediaUrl: _mediaUrlController.text.isNotEmpty ? _mediaUrlController.text : null, // Added
          loaiBangLaiId: _selectedLoaiBangLaiId,
          chuDeId: _selectedChuDeId,
        );

        bool success;
        if (widget.cauHoi == null) {
          success = await ApiCauHoiService.createCauHoi(newCauHoi);
        } else {
          success = await ApiCauHoiService.updateCauHoi(newCauHoi);
        }

        if (success && mounted) {
          Navigator.pop(context, true); // Return true to refresh list
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.cauHoi == null ? 'Thêm thành công' : 'Cập nhật thành công')),
          );
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
    String title = widget.cauHoi == null ? 'Thêm Câu Hỏi' : 'Sửa Câu Hỏi';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: _isLoading && _loaiBangLais.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Image Preview Area
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text("Hình ảnh minh họa", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Builder(
                              builder: (context) {
                                 const String serverUrl = 'http://10.0.2.2:5084';
                                 final String rawUrl = _mediaUrlController.text;
                                 final String imageUrl = (rawUrl.isNotEmpty)
                                     ? (rawUrl.startsWith('http') ? rawUrl : '$serverUrl$rawUrl')
                                     : '';
                                 
                                 if (imageUrl.isEmpty) {
                                   return Container(
                                     height: 150, 
                                     width: double.infinity,
                                     color: Colors.grey.shade100, 
                                     child: const Column(
                                       mainAxisAlignment: MainAxisAlignment.center,
                                       children: [
                                          Icon(Icons.image, size: 50, color: Colors.grey),
                                          SizedBox(height: 8),
                                          Text("Chưa có ảnh (tùy chọn)", style: TextStyle(color: Colors.grey))
                                       ],
                                     )
                                   );
                                 }
                                 
                                 return Image.network(
                                   imageUrl,
                                   height: 200,
                                   fit: BoxFit.contain,
                                   errorBuilder: (_, __, ___) => Container(
                                     height: 150, 
                                     width: double.infinity,
                                     color: Colors.grey.shade100,
                                     child: const Column(
                                       mainAxisAlignment: MainAxisAlignment.center,
                                       children: [
                                         Icon(Icons.broken_image, size: 40, color: Colors.red),
                                         SizedBox(height: 4),
                                         Text("Lỗi tải ảnh", style: TextStyle(fontSize: 12))
                                       ],
                                     ),
                                   ),
                                 );
                              }
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextFormField(
                      controller: _mediaUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Link Ảnh (URL hoặc đường dẫn tương đối)', 
                        border: OutlineInputBorder(),
                        hintText: 'ví dụ: /images/bien_bao_cam.png'
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _noiDungController,
                      decoration: const InputDecoration(labelText: 'Nội dung câu hỏi', border: OutlineInputBorder()),
                      maxLines: 3,
                      validator: (v) => v!.isEmpty ? 'Nhập nội dung' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedLoaiBangLaiId,
                      decoration: const InputDecoration(labelText: 'Loại Bằng Lái', border: OutlineInputBorder()),
                      items: _loaiBangLais.map((e) => DropdownMenuItem(value: e.id, child: Text(e.tenLoai))).toList(),
                      onChanged: (v) => setState(() => _selectedLoaiBangLaiId = v),
                      validator: (v) => v == null ? 'Chọn loại bằng lái' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedChuDeId,
                      decoration: const InputDecoration(labelText: 'Chủ Đề', border: OutlineInputBorder()),
                      items: _chuDes.map((e) => DropdownMenuItem(value: e.id, child: Text(e.tenChuDe))).toList(),
                      onChanged: (v) => setState(() => _selectedChuDeId = v),
                      validator: (v) => v == null ? 'Chọn chủ đề' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildOptionField('Lựa chọn A', _luaChonAController),
                    _buildOptionField('Lựa chọn B', _luaChonBController),
                    _buildOptionField('Lựa chọn C', _luaChonCController, required: false),
                    _buildOptionField('Lựa chọn D', _luaChonDController, required: false),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _dapAnDung,
                      decoration: const InputDecoration(labelText: 'Đáp án đúng', border: OutlineInputBorder()),
                      items: ['A', 'B', 'C', 'D'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _dapAnDung = v!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _giaiThichController,
                      decoration: const InputDecoration(labelText: 'Giải thích', border: OutlineInputBorder()),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Câu hỏi điểm liệt'),
                      value: _diemLiet,
                      onChanged: (v) => setState(() => _diemLiet = v!),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isLoading ? null : _submit,
                      child: Text(_isLoading ? 'Đang xử lý...' : 'LƯU CÂU HỎI'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOptionField(String label, TextEditingController controller, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: required ? (v) => v!.isEmpty ? 'Nhập $label' : null : null,
      ),
    );
  }
}
