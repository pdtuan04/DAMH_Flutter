import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../models/mo_phong.dart';
import '../../../models/loai_bang_lai.dart';
import '../../../services/mo_phong_api_service.dart';
import '../../../services/loai_bang_lai_api.dart';
import '../../../services/upload_service.dart';

class MoPhongFormCreate extends StatefulWidget {
  final MoPhong? moPhong;

  const MoPhongFormCreate({Key? key, this.moPhong}) : super(key: key);

  @override
  _MoPhongFormCreateState createState() => _MoPhongFormCreateState();
}

class _MoPhongFormCreateState extends State<MoPhongFormCreate> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _noiDungController;
  late TextEditingController _videoUrlController;
  late TextEditingController _dapAnController;

  bool _isLoading = false;
  bool _isUploading = false;
  List<LoaiBangLai> _loaiBangLaiList = [];
  String? _selectedLoaiBangLaiId;
  File? _selectedVideoFile;
  final ImagePicker _picker = ImagePicker();

  // Video player
  VideoPlayerController? _videoController;
  bool _isVideoReady = false;

  // Mốc thời gian
  List<double> _mocThoiGian = [];
  final List<Color> _mauMoc = [
    Colors.green,     
    Colors.red,        
    Colors.orange,     
    Colors.blue,     
    Colors.purple,     
    Colors.grey,       
  ];

  // Focus node để bắt phím
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _noiDungController = TextEditingController(text: widget.moPhong?.noiDung ?? '');
    _videoUrlController = TextEditingController(text: widget.moPhong?.videoUrl ?? '');
    _dapAnController = TextEditingController(text: widget.moPhong?.dapAn ?? '');
    _selectedLoaiBangLaiId = widget.moPhong?.loaiBangLaiId;

    // Nếu đang sửa và có đáp án, parse mốc thời gian
    if (widget.moPhong != null && widget.moPhong!.dapAn.isNotEmpty) {
      _mocThoiGian = widget.moPhong!.getDanhSachMocThoiGian();
    }

    _loadLoaiBangLai();

    // Nếu đang sửa và có video URL, load video
    if (widget.moPhong != null && widget.moPhong!.videoUrl.isNotEmpty) {
      _initVideoFromUrl(widget.moPhong!.videoUrl);
    }
  }

  @override
  void dispose() {
    _noiDungController.dispose();
    _videoUrlController.dispose();
    _dapAnController.dispose();
    _videoController?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadLoaiBangLai() async {
    try {
      final list = await ApiLoaiBangLaiService.getAll();
      setState(() => _loaiBangLaiList = list);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi tải loại bằng lái: $e'))
        );
      }
    }
  }

  // Xin quyền truy cập
  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      // Thử xin quyền videos trước (Android 13+)
      var status = await Permission.videos.request();
      if (status.isGranted) return true;
      
      // Nếu không được, thử storage (Android cũ)
      status = await Permission.storage.request();
      if (status.isGranted) return true;
      
      // Nếu vẫn không được, kiểm tra photos
      status = await Permission.photos.request();
      return status.isGranted;
    }
    return true; // iOS không cần xin quyền trước
  }

  // Khởi tạo video từ URL
  Future<void> _initVideoFromUrl(String url) async {
    try {
      // Nếu URL bắt đầu bằng /, thêm base URL
      String videoUrl = url;
      if (url.startsWith('/')) {
        videoUrl = 'http://10.0.2.2:5084$url';
      }

      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _videoController!.initialize();
      setState(() => _isVideoReady = true);

      // Lắng nghe thay đổi video để cập nhật progress
      _videoController!.addListener(() {
        if (mounted) setState(() {});
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi load video: $e'))
        );
      }
    }
  }

  // Khởi tạo video từ file
  Future<void> _initVideoFromFile(File file) async {
    try {
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(file);
      await _videoController!.initialize();
      setState(() => _isVideoReady = true);

      // Lắng nghe thay đổi video
      _videoController!.addListener(() {
        if (mounted) setState(() {});
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi load video: $e'))
        );
      }
    }
  }

  // Chọn video từ máy
  Future<void> _chonVideo() async {
    try {
      // Xin quyền trước khi chọn video
      final hasPermission = await _requestPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cần cấp quyền truy cập để chọn video'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            )
          );
          
          // Mở settings để user cấp quyền
          await Future.delayed(const Duration(seconds: 1));
          await openAppSettings();
        }
        return;
      }

      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      
      if (video != null) {
        setState(() {
          _selectedVideoFile = File(video.path);
          _isUploading = true;
          _isVideoReady = false;
        });

        // Hiển thị video ngay lập tức
        await _initVideoFromFile(_selectedVideoFile!);

        // Upload video lên server
        final videoUrl = await UploadService.uploadVideo(_selectedVideoFile!);
        
        if (videoUrl != null && mounted) {
          setState(() {
            _videoUrlController.text = videoUrl;
            _isUploading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Upload video thành công!'),
              backgroundColor: Colors.green,
            )
          );
        } else {
          setState(() => _isUploading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Upload video thất bại!'),
                backgroundColor: Colors.red,
              )
            );
          }
        }
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          )
        );
      }
    }
  }

  // Xử lý phím Space để thêm mốc thời gian
  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      _themMocThoiGian();
    }
  }

  // Thêm mốc thời gian tại vị trí hiện tại của video
  void _themMocThoiGian() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn video trước!'))
      );
      return;
    }

    if (_mocThoiGian.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đủ 6 mốc thời gian!'))
      );
      return;
    }

    final currentTime = _videoController!.value.position.inMilliseconds / 1000;
    setState(() {
      _mocThoiGian.add(currentTime);
      _mocThoiGian.sort(); // Sắp xếp theo thứ tự tăng dần
      _dapAnController.text = _mocThoiGian.map((m) => m.toStringAsFixed(1)).join(',');
    });
  }

  // Làm lại mốc thời gian
  void _lamLaiMoc() {
    setState(() {
      _mocThoiGian.clear();
      _dapAnController.text = '';
    });
    _videoController?.seekTo(Duration.zero);
    _videoController?.play();
  }

  // Xóa mốc thời gian
  void _xoaMoc(int index) {
    setState(() {
      _mocThoiGian.removeAt(index);
      _dapAnController.text = _mocThoiGian.map((m) => m.toStringAsFixed(1)).join(',');
    });
  }

  // Gửi form
  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedLoaiBangLaiId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng chọn loại bằng lái'))
        );
        return;
      }

      if (_mocThoiGian.length != 6) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phải có đúng 6 mốc thời gian!'))
        );
        return;
      }

      setState(() => _isLoading = true);
      try {
        final newItem = MoPhong(
          id: widget.moPhong?.id ?? '',
          noiDung: _noiDungController.text,
          videoUrl: _videoUrlController.text,
          dapAn: _dapAnController.text,
          loaiBangLaiId: _selectedLoaiBangLaiId!,
        );

        bool success;
        if (widget.moPhong == null) {
          success = await ApiMoPhongService.create(newItem);
        } else {
          success = await ApiMoPhongService.update(newItem);
        }

        if (success && mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.moPhong == null ? 'Thêm thành công' : 'Cập nhật thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red)
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.moPhong == null ? 'Thêm Mô Phỏng' : 'Sửa Mô Phỏng';

    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKeyPress,
      autofocus: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.blue,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nội dung
                TextFormField(
                  controller: _noiDungController,
                  decoration: const InputDecoration(
                    labelText: 'Nội dung câu hỏi',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.text_fields),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập nội dung';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Nút chọn video
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _chonVideo,
                        icon: _isUploading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.video_library),
                        label: Text(_isUploading ? 'Đang upload...' : 'Chọn video từ máy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 50),
                        ),
                      ),
                    ),
                  ],
                ),

                // Video Player
                if (_isVideoReady && _videoController != null)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      // Video
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Thời gian hiện tại
                      Text(
                        _formatDuration(_videoController!.value.position),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // Progress bar với mốc thời gian
                      SizedBox(
                        height: 40,
                        child: Stack(
                          children: [
                            // Progress bar chính
                            Positioned.fill(
                              child: VideoProgressIndicator(
                                _videoController!,
                                allowScrubbing: true,
                                colors: VideoProgressColors(
                                  playedColor: Colors.blue,
                                  bufferedColor: Colors.grey.shade300,
                                  backgroundColor: Colors.grey.shade200,
                                ),
                              ),
                            ),

                            // Vẽ các mốc thời gian
                            ...List.generate(_mocThoiGian.length, (index) {
                              final duration = _videoController!.value.duration.inMilliseconds / 1000;
                              if (duration == 0) return const SizedBox();
                              
                              final position = (_mocThoiGian[index] / duration);
                              
                              return Positioned(
                                left: position * MediaQuery.of(context).size.width * 0.9,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 3,
                                  color: _mauMoc[index],
                                  child: Center(
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: _mauMoc[index],
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Nút điều khiển video
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(_videoController!.value.isPlaying 
                              ? Icons.pause 
                              : Icons.play_arrow),
                            iconSize: 40,
                            onPressed: () {
                              setState(() {
                                if (_videoController!.value.isPlaying) {
                                  _videoController!.pause();
                                } else {
                                  _videoController!.play();
                                }
                              });
                            },
                          ),
                          const SizedBox(width: 16),
                          TextButton.icon(
                            onPressed: _themMocThoiGian,
                            icon: const Icon(Icons.add_location_alt),
                            label: Text('Thêm mốc (${_mocThoiGian.length}/6)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _lamLaiMoc,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Làm lại'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Hiển thị danh sách mốc
                      if (_mocThoiGian.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Các mốc thời gian đã chọn:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: List.generate(_mocThoiGian.length, (index) {
                                  return Chip(
                                    backgroundColor: _mauMoc[index],
                                    label: Text(
                                      '${index + 1}. ${_mocThoiGian[index].toStringAsFixed(1)}s',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    deleteIcon: const Icon(Icons.close, color: Colors.white, size: 18),
                                    onDeleted: () => _xoaMoc(index),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                const SizedBox(height: 16),

                // Đáp án (readonly)
                TextFormField(
                  controller: _dapAnController,
                  decoration: const InputDecoration(
                    labelText: 'Đáp án',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.timer),
                    helperText: 'Nhấn phím cách (Space) để chọn 6 mốc thời gian',
                  ),
                  readOnly: true,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Dropdown Loại Bằng Lái
                DropdownButtonFormField<String>(
                  value: _selectedLoaiBangLaiId,
                  decoration: const InputDecoration(
                    labelText: 'Loại Bằng Lái',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.card_membership),
                  ),
                  items: _loaiBangLaiList.map((loai) {
                    return DropdownMenuItem<String>(
                      value: loai.id,
                      child: Text(loai.tenLoai),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedLoaiBangLaiId = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Vui lòng chọn loại bằng lái';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Nút Submit
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_isLoading || _isUploading) ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      widget.moPhong == null ? 'Thêm Mô Phỏng' : 'Cập Nhật',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}