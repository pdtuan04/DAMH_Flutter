import 'package:flutter/material.dart';
import '../../../models/loai_bang_lai.dart';
import '../../../services/loai_bang_lai_api.dart';

class LoaiBangLaiFormCreate extends StatefulWidget {
  final LoaiBangLai? loaiBangLai;

  const LoaiBangLaiFormCreate({Key? key, this.loaiBangLai}) : super(key: key);

  @override
  _LoaiBangLaiFormCreateState createState() => _LoaiBangLaiFormCreateState();
}

class _LoaiBangLaiFormCreateState extends State<LoaiBangLaiFormCreate> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tenLoaiController;
  late TextEditingController _moTaController;
  late TextEditingController _loaiXeController;
  late TextEditingController _thoiGianThiController;
  late TextEditingController _diemToiThieuController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tenLoaiController = TextEditingController(text: widget.loaiBangLai?.tenLoai ?? '');
    _moTaController = TextEditingController(text: widget.loaiBangLai?.moTa ?? '');
    _loaiXeController = TextEditingController(text: widget.loaiBangLai?.loaiXe ?? '');
    _thoiGianThiController = TextEditingController(text: widget.loaiBangLai?.thoiGianThi.toString() ?? '');
    _diemToiThieuController = TextEditingController(text: widget.loaiBangLai?.diemToiThieu.toString() ?? '');
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final newItem = LoaiBangLai(
          id: widget.loaiBangLai?.id ?? '',
          tenLoai: _tenLoaiController.text,
          moTa: _moTaController.text,
          loaiXe: _loaiXeController.text,
          thoiGianThi: int.parse(_thoiGianThiController.text),
          diemToiThieu: int.parse(_diemToiThieuController.text),
        );

        bool success;
        if (widget.loaiBangLai == null) {
          success = await ApiLoaiBangLaiService.create(newItem);
        } else {
          success = await ApiLoaiBangLaiService.update(newItem);
        }

        if (success && mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.loaiBangLai == null ? 'Thêm thành công' : 'Cập nhật thành công')),
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
    String title = widget.loaiBangLai == null ? 'Thêm Loại Bằng Lái' : 'Sửa Loại Bằng Lái';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tenLoaiController,
                decoration: const InputDecoration(labelText: 'Tên Loại', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Nhập tên loại' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _moTaController,
                decoration: const InputDecoration(labelText: 'Mô Tả', border: OutlineInputBorder()),
                maxLines: 2,
                validator: (v) => v!.isEmpty ? 'Nhập mô tả' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _loaiXeController,
                decoration: const InputDecoration(labelText: 'Loại Xe (ví dụ: Xe máy)', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Nhập loại xe' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _thoiGianThiController,
                decoration: const InputDecoration(labelText: 'Thời Gian Thi (phút)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty || int.tryParse(v) == null ? 'Nhập thời gian thi hợp lệ' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _diemToiThieuController,
                decoration: const InputDecoration(labelText: 'Điểm Tối Thiểu', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty || int.tryParse(v) == null ? 'Nhập điểm tối thiểu hợp lệ' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                onPressed: _isLoading ? null : _submit,
                child: Text(_isLoading ? 'Đang xử lý...' : 'LƯU'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
