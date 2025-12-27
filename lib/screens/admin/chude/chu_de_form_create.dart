import 'package:flutter/material.dart';
import '../../../models/chu_de.dart';
import '../../../services/chu_de_service_api.dart';

class ChuDeFormCreate extends StatefulWidget {
  final ChuDe? chuDe;

  const ChuDeFormCreate({Key? key, this.chuDe}) : super(key: key);

  @override
  _ChuDeFormCreateState createState() => _ChuDeFormCreateState();
}

class _ChuDeFormCreateState extends State<ChuDeFormCreate> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tenChuDeController;
  late TextEditingController _moTaController;
  late TextEditingController _imageUrlController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tenChuDeController = TextEditingController(text: widget.chuDe?.tenChuDe ?? '');
    _moTaController = TextEditingController(text: widget.chuDe?.moTa ?? '');
    _imageUrlController = TextEditingController(text: widget.chuDe?.imageUrl ?? '');
    
    // Listen to changes to update preview
    _imageUrlController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tenChuDeController.dispose();
    _moTaController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final newItem = ChuDe(
          id: widget.chuDe?.id ?? '',
          tenChuDe: _tenChuDeController.text,
          moTa: _moTaController.text,
          imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
        );

        bool success;
        if (widget.chuDe == null) {
          success = await ApiChuDeService.create(newItem);
        } else {
          success = await ApiChuDeService.update(newItem);
        }

        if (success && mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.chuDe == null ? 'Thêm thành công' : 'Cập nhật thành công')),
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
    String title = widget.chuDe == null ? 'Thêm Chủ Đề' : 'Sửa Chủ Đề';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    const Text("Hình ảnh", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Builder(
                        builder: (context) {
                           const String serverUrl = 'http://10.0.2.2:5084';
                           final String rawUrl = _imageUrlController.text;
                           final String imageUrl = (rawUrl.isNotEmpty)
                               ? (rawUrl.startsWith('http') ? rawUrl : '$serverUrl$rawUrl')
                               : '';
                           
                           if (imageUrl.isEmpty) {
                             return Container(
                               height: 150, 
                               width: 150,
                               color: Colors.grey.shade100, 
                               child: const Icon(Icons.image, size: 50, color: Colors.grey)
                             );
                           }
                           
                           return Image.network(
                             imageUrl,
                             height: 150,
                             fit: BoxFit.contain,
                             errorBuilder: (_, __, ___) => Container(
                               height: 150, 
                               width: 150,
                               color: Colors.grey.shade100,
                               child: const Column(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   Icon(Icons.broken_image, size: 40, color: Colors.red),
                                   SizedBox(height: 4),
                                   Text("Lỗi ảnh", style: TextStyle(fontSize: 12))
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
                controller: _tenChuDeController,
                decoration: const InputDecoration(labelText: 'Tên Chủ Đề', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Nhập tên chủ đề' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _moTaController,
                decoration: const InputDecoration(labelText: 'Mô Tả', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Nhập mô tả' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Link Ảnh (URL hoặc đường dẫn tương đối)', 
                  border: OutlineInputBorder(),
                  hintText: 'ví dụ: /images/icon_car.png'
                ),
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
