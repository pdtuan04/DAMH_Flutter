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
        // 1. Thanh dải màu điểm (Nằm sát trên thanh chạy)
        SizedBox(
          height: 15,
          width: double.infinity,
          child: CustomPaint(
            painter: ScoreBarPainter(
              markers: widget.moPhong.dapAn.split(',').map((e) => double.parse(e.trim())).toList(),
              totalTime: totalTime,
              flagTime: _flagTime,
              showColors: _hasPressed,
            ),
          ),
        ),
        // 2. Thanh chạy thời gian thực (Slim & Clean)
        Container(
          height: 6,
          width: double.infinity,
          color: Colors.grey[300],
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(color: Colors.indigo),
              ),
              // Vị trí cờ đỏ kéo dài xuống thanh chạy
              // Vị trí cờ đỏ bằng hình ảnh
              if (_flagTime != null)
                Positioned(
                  // Tính toán vị trí X y hệt như cũ để đảm bảo chính xác 100%
                  left: (_flagTime! / totalTime) * MediaQuery.of(context).size.width - 10, // trừ 10 để căn giữa icon
                  top: -15, // Đẩy icon cờ lên phía trên thanh màu một chút
                  child: Image.asset(
                    'assets/images/red_flag.png', // Đường dẫn file cờ bạn tải về
                    width: 25,
                    height: 25,
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
  final double? flagTime;
  final bool showColors;

  ScoreBarPainter({required this.markers, required this.totalTime, this.flagTime, required this.showColors});

  @override
  void paint(Canvas canvas, Size size) {
    if (showColors) {
      final colors = [Colors.green, Colors.lightGreen, Colors.yellow, Colors.orange, Colors.red];
      for (int i = 0; i < 5; i++) {
        final paint = Paint()..color = colors[i];
        double left = (markers[i] / totalTime) * size.width;
        double right = (markers[i + 1] / totalTime) * size.width;
        canvas.drawRect(Rect.fromLTRB(left, 0, right, size.height), paint);
      }
    }

    if (flagTime != null) {
      final flagPaint = Paint()..color = Colors.redAccent..strokeWidth = 2.5;
      double flagPos = (flagTime! / totalTime) * size.width;

      // Vẽ cờ đỏ thẳng đứng xuyên suốt dải màu
      canvas.drawLine(Offset(flagPos, 0), Offset(flagPos, size.height), flagPaint);

      // Hình tam giác cờ ở đỉnh
      final path = Path();
      path.moveTo(flagPos, 0);
      path.lineTo(flagPos + 10, 4);
      path.lineTo(flagPos, 8);
      path.close();
      canvas.drawPath(path, Paint()..color = Colors.redAccent);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}