import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart'; // Import thư viện
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
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(fullUrl),// Giúp âm thanh mượt hơn
    )..initialize().then((_) {
      if (mounted) {
        setState(() => _isInitialized = true);
        _controller.play();
      }
    }).catchError((error) {
      print("Lỗi tải video: $error");
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
    try {
      List<double> markers = widget.moPhong.dapAn.split(',').map((e) => double.parse(e.trim())).toList();
      if (time >= markers[0] && time < markers[1]) return 5;
      if (time >= markers[1] && time < markers[2]) return 4;
      if (time >= markers[2] && time < markers[3]) return 3;
      if (time >= markers[3] && time < markers[4]) return 2;
      if (time >= markers[4] && time < markers[5]) return 1;
    } catch (e) { print(e); }
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
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Mô Phỏng Tình Huống"), centerTitle: true),
      body: Column(
        children: [
          _buildVideoSection(),
          _buildNewProgressSystem(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(widget.moPhong.noiDung, textAlign: TextAlign.center),
                  ),
                  _buildResultBoard(),
                ],
              ),
            ),
          ),
          _buildControls(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  Widget _buildVideoSection() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: _isInitialized ? VideoPlayer(_controller) : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
  Widget _buildNewProgressSystem() {
    if (!_isInitialized) return const LinearProgressIndicator();
    return ValueListenableBuilder(
      valueListenable: _controller,
      builder: (context, VideoPlayerValue value, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    height: 5,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: ScoreBarPainter(
                        markers: widget.moPhong.dapAn.split(',').map((e) => double.parse(e.trim())).toList(),
                        totalTime: value.duration.inSeconds.toDouble(),
                        showColors: _hasPressed,
                      ),
                    ),
                  ),
                  ProgressBar(
                    progress: value.position,
                    total: value.duration,
                    buffered: value.buffered.isNotEmpty ? value.buffered.last.end : Duration.zero,
                    onSeek: (duration) => _controller.seekTo(duration),
                    barHeight: 5.0,
                    thumbRadius: 7.0,
                    timeLabelLocation: TimeLabelLocation.none,
                  ),
                  if (_flagTime != null)
                    Positioned(
                      left: (_flagTime! / value.duration.inSeconds) * (MediaQuery.of(context).size.width - 32),
                      top: -15, // Đẩy cờ lên trên thanh progress
                      child: const Icon(Icons.flag, color: Colors.red, size: 20),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
  Widget _buildResultBoard() {
    if (!_hasPressed) return const SizedBox.shrink();
    return Column(
      children: [
        const Text("ĐIỂM SỐ"),
        Text("$_score", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: _score > 0 ? Colors.green : Colors.red)),
      ],
    );
  }
  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _hasPressed ? null : _onFlagPressed,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text("CẮM CỜ"),
            ),
          ),
          if (_hasPressed) ...[
            const SizedBox(width: 10),
            IconButton(onPressed: _reset, icon: const Icon(Icons.refresh)),
          ]
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
  ScoreBarPainter({required this.markers, required this.totalTime, required this.showColors});
  @override
  void paint(Canvas canvas, Size size) {
    if (!showColors || totalTime <= 0) return;
    final colors = [Colors.green, Colors.lightGreen, Colors.yellow, Colors.orange, Colors.redAccent];
    for (int i = 0; i < 5; i++) {
      if (i + 1 < markers.length) {
        final paint = Paint()..color = colors[i];
        double left = (markers[i] / totalTime) * size.width;
        double right = (markers[i + 1] / totalTime) * size.width;
        canvas.drawRect(Rect.fromLTRB(left, 0, right, size.height), paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant ScoreBarPainter oldDelegate) => oldDelegate.showColors != showColors;
}