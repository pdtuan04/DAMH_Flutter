import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../../../models/chu_de.dart';
import '../../../services/chu_de_service_api.dart';
import '../../../services/upload_service.dart';

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
  
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tenChuDeController = TextEditingController(text: widget.chuDe?.tenChuDe ?? '');
    _moTaController = TextEditingController(text: widget.chuDe?.moTa ?? '');
    _imageUrlController = TextEditingController(text: widget.chuDe?.imageUrl ?? '');
    

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

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, 
        maxWidth: 1920,   
      );
      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Lỗi chọn ảnh: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể chọn ảnh')));
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        if (_pickedImage != null) {
          final uploadedPath = await UploadService.uploadImage(_pickedImage!);
          if (uploadedPath != null) {
            _imageUrlController.text = uploadedPath;
          }
        }

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
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Hình ảnh", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          TextButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image),
                            label: const Text("Chọn ảnh"),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Builder(
                          builder: (context) {
                             if (_pickedImage != null) {
                               return Image.file(
                                 _pickedImage!,
                                 height: 150,
                                 fit: BoxFit.contain,
                               );
                             }
                             const String serverUrl = 'http://10.0.2.2:5084';
                             final String rawUrl = _imageUrlController.text;
                             
                             if (rawUrl.isNotEmpty) {
                                bool isNetwork = rawUrl.startsWith('http') || 
                                                 rawUrl.startsWith('/images/') || 
                                                 rawUrl.startsWith('/videos/');                         
                                if (!isNetwork) {
                                  return Image.file(
                                    File(rawUrl),
                                    height: 250,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Column( 
                                       mainAxisAlignment: MainAxisAlignment.center,
                                       children: [
                                          Icon(Icons.broken_image, size: 40, color: Colors.red),
                                          Text("Lỗi ảnh (Local)", style: TextStyle(fontSize: 10))
                                       ],
                                    ),
                                  );
                                }

                                final String imageUrl = rawUrl.startsWith('http') ? rawUrl : '$serverUrl$rawUrl';
                                return Image.network(
                                   imageUrl,
                                   height: 250,
                                   width: double.infinity,
                                   fit: BoxFit.contain,
                                   errorBuilder: (_, __, ___) => const Column(
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     children: [
                                       Icon(Icons.broken_image, size: 40, color: Colors.red),
                                       Text("Lỗi ảnh (Mạng)", style: TextStyle(fontSize: 10))
                                     ],
                                   ),
                                 );
                             }
                             
                             return Container(
                               height: 150, 
                               width: 150,
                               color: Colors.grey.shade200, 
                               child: const Column(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                                   SizedBox(height: 8),
                                   Text("Bấm để chọn ảnh", style: TextStyle(color: Colors.grey))
                                 ],
                               )
                             );
                          }
                        ),
                      ),
                    ],
                  ),
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
              Visibility(
                visible: false, 
                child: TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Link Ảnh (URL hoặc đường dẫn tương đối)', 
                    border: OutlineInputBorder(),
                  ),
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
