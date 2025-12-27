import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/mo_phong.dart';

class MoPhongScreen extends StatefulWidget {
  final MoPhong moPhong;
  const MoPhongScreen({super.key, required this.moPhong});

  @override
  State<MoPhongScreen> createState() => _MoPhongScreenState();
}

class _MoPhongScreenState extends State<MoPhongScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasPressed = false;
  int _score = 0;
  double? _flagTime;

  @override
  void initState() {
    super.initState();
    _startVideo();
  }

  void _startVideo() {
    final String fullUrl = 'http://10.0.2.2:5084${widget.moPhong.videoUrl}';
    _controller = VideoPlayerController.networkUrl(Uri.parse(fullUrl))
      ..initialize().then((_) {
        setState(() => _isInitialized = true);
        _controller.play();
        _controller.addListener(() => setState(() {})); // Cập nhật thanh chạy liên tục
      });
  }

  void _onFlagPressed() {
    if (_hasPressed || !_isInitialized) return;
    setState(() {
      _hasPressed = true;
      _flagTime = _controller.value.position.inMilliseconds / 1000.0;
      _score = _calculateScore(_flagTime!);
    });
  }

  int _calculateScore(double time) {
    List<double> markers = widget.moPhong.dapAn.split(',').map((e) => double.parse(e.trim())).toList();
    if (time >= markers[0] && time < markers[1]) return 10;
    if (time >= markers[1] && time < markers[2]) return 8;
    if (time >= markers[2] && time < markers[3]) return 6;
    if (time >= markers[3] && time < markers[4]) return 4;
    if (time >= markers[4] && time < markers[5]) return 2;
    return 0;
  }

  void _reset() {
    setState(() {
      _hasPressed = false;
      _score = 0;
      _flagTime = null;
    });
    _controller.seekTo(Duration.zero);
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Mô Phỏng Tình Huống"), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildVideoPlayer(),
            _buildCustomProgressSystem(), // Hệ thống thanh tiến trình mới
            _buildResultBoard(),
            const SizedBox(height: 20),
            _buildControls(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Text(widget.moPhong.noiDung, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
    );
  }

  Widget _buildVideoPlayer() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: _isInitialized ? VideoPlayer(_controller) : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  // --- HỆ THỐNG THANH TIẾN TRÌNH TÙY CHỈNH ---
  Widget _buildCustomProgressSystem() {
    if (!_isInitialized) return const SizedBox(height: 30);

    double totalTime = _controller.value.duration.inMilliseconds / 1000.0;
    double currentTime = _controller.value.position.inMilliseconds / 1000.0;
    double progress = currentTime / totalTime;

    return Column(
      children: [
        // Thanh dải màu điểm
        SizedBox(
          height: 15,
          width: double.infinity,
          child: CustomPaint(
            painter: ScoreBarPainter(
              markers: widget.moPhong.dapAn.split(',').map((e) => double.parse(e.trim())).toList(),
              totalTime: totalTime,
              showColors: _hasPressed,
            ),
          ),
        ),
        // Thanh chạy thời gian thực
        Container(
          height: 6,
          width: double.infinity,
          color: Colors.grey[300],
          child: Stack(
            clipBehavior: Clip.none, // Cho phép ảnh cờ hiển thị tràn ra ngoài Stack
            children: [
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(color: Colors.indigo),
              ),
              // HIỂN THỊ CỜ BẰNG ẢNH TẠI ĐÂY
              if (_flagTime != null)
                Positioned(
                  // Căn chỉnh vị trí cờ dựa trên thời gian đã bấm
                  left: (_flagTime! / totalTime) * MediaQuery.of(context).size.width - 12.5,
                  top: -25, // Đẩy cờ lên trên thanh tiến trình
                  child: Image.asset(
                    'assets/images/red_flag.png',
                    width: 25,
                    height: 25,
                    fit: BoxFit.contain,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultBoard() {
    if (!_hasPressed) return const SizedBox(height: 80);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text("ĐIỂM: $_score", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _score > 0 ? Colors.green : Colors.red)),
          const SizedBox(height: 8),
          Icon(_score == 5 ? Icons.stars : Icons.info_outline, color: _score > 0 ? Colors.green : Colors.red, size: 40),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _hasPressed ? null : _onFlagPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                disabledBackgroundColor: Colors.grey[400],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("PHANH NGAY", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          if (_hasPressed)
            TextButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh),
              label: const Text("THỬ LẠI"),
              style: TextButton.styleFrom(foregroundColor: Colors.indigo, padding: const EdgeInsets.only(top: 20)),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ScoreBarPainter extends CustomPainter {
  final List<double> markers;
  final double totalTime;
  final bool showColors;

  ScoreBarPainter({
    required this.markers,
    required this.totalTime,
    required this.showColors
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (showColors) {
      // Vẽ dải màu tương ứng với các mốc điểm
      final colors = [Colors.green, Colors.lightGreen, Colors.yellow, Colors.orange, Colors.red];
      for (int i = 0; i < 5; i++) {
        if (i + 1 < markers.length) {
          final paint = Paint()..color = colors[i];
          double left = (markers[i] / totalTime) * size.width;
          double right = (markers[i + 1] / totalTime) * size.width;
          canvas.drawRect(Rect.fromLTRB(left, 0, right, size.height), paint);
        }
      }
    }
    // Đã xóa phần vẽ Line và Path của cờ đỏ ở đây
  }

  @override
  bool shouldRepaint(covariant ScoreBarPainter oldDelegate) {
    return oldDelegate.showColors != showColors || oldDelegate.markers != markers;
  }
}