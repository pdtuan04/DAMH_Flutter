import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:provider/provider.dart';
import '../models/mo_phong.dart';
import '../providers/mo_phong_provider.dart';

class MoPhongScreen extends StatelessWidget {
  final MoPhong moPhong;
  const MoPhongScreen({super.key, required this.moPhong});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MoPhongProvider(moPhong: moPhong),
      child:  Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Mô Phỏng Tình Huống"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            const _VideoSection(),
            const _ProgressSection(),
            Expanded(
              child: SingleChildScrollView(
                child:  Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        moPhong.noiDung,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const _ResultBoard(),
                  ],
                ),
              ),
            ),
            const _Controls(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ✅ Video Section - Chỉ rebuild khi isInitialized thay đổi
class _VideoSection extends StatelessWidget {
  const _VideoSection();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child:  Selector<MoPhongProvider, bool>(
          selector:  (_, provider) => provider.isInitialized,
          builder: (context, isInitialized, child) {
            if (!isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }
            final controller = context.read<MoPhongProvider>().controller;
            return VideoPlayer(controller);
          },
        ),
      ),
    );
  }
}

// ✅ Progress Section - Tối ưu rebuild
class _ProgressSection extends StatelessWidget {
  const _ProgressSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MoPhongProvider>();

    return Selector<MoPhongProvider, bool>(
      selector: (_, p) => p.isInitialized,
      builder:  (context, isInitialized, child) {
        if (!isInitialized) return const LinearProgressIndicator();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            height: 30,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ✅ Thanh màu static - chỉ rebuild khi hasPressed thay đổi
                Selector<MoPhongProvider, bool>(
                  selector: (_, p) => p.hasPressed,
                  builder: (context, hasPressed, child) {
                    if (! hasPressed) return const SizedBox.shrink();

                    return Positioned. fill(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter:  ScoreBarPainter(
                            markers: provider.markers,
                            totalTime: provider. controller.value.duration.inSeconds. toDouble(),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // ✅ Progress bar - rebuild mỗi frame NHƯNG không ảnh hưởng các widget khác
                ValueListenableBuilder(
                  valueListenable:  provider.controller,
                  builder: (context, VideoPlayerValue value, child) {
                    return ProgressBar(
                      progress: value.position,
                      total: value.duration,
                      buffered: value.buffered. isNotEmpty
                          ? value.buffered. last.end
                          : Duration.zero,
                      onSeek: (duration) => provider.controller.seekTo(duration),
                      barHeight: 5.0,
                      thumbRadius: 7.0,
                      timeLabelLocation: TimeLabelLocation.none,
                    );
                  },
                ),

                // ✅ Cờ static - chỉ rebuild khi flagTime thay đổi
                Selector<MoPhongProvider, double?>(
                  selector: (_, p) => p.flagTime,
                  builder: (context, flagTime, child) {
                    if (flagTime == null) return const SizedBox.shrink();

                    final duration = provider.controller.value.duration. inSeconds;
                    if (duration == 0) return const SizedBox.shrink();

                    return Positioned(
                      left: (flagTime / duration) *
                          (MediaQuery.of(context).size.width - 32),
                      top: -15,
                      child: const Icon(Icons.flag, color: Colors.red, size: 20),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ✅ Result Board - chỉ rebuild khi hasPressed hoặc score thay đổi
class _ResultBoard extends StatelessWidget {
  const _ResultBoard();

  @override
  Widget build(BuildContext context) {
    return Selector<MoPhongProvider, ({bool hasPressed, int score})>(
      selector: (_, p) => (hasPressed:  p.hasPressed, score: p.score),
      builder: (context, data, child) {
        if (! data.hasPressed) return const SizedBox.shrink();

        return Column(
          children: [
            const Text("ĐIỂM SỐ"),
            Text(
              "${data.score}",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: data.score > 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ✅ Controls - chỉ rebuild khi hasPressed thay đổi
class _Controls extends StatelessWidget {
  const _Controls();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets. symmetric(horizontal: 16),
      child:  Selector<MoPhongProvider, bool>(
        selector: (_, p) => p.hasPressed,
        builder: (context, hasPressed, child) {
          final provider = context.read<MoPhongProvider>();

          return Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: hasPressed ? null : provider.onFlagPressed,
                  style: ElevatedButton. styleFrom(
                    backgroundColor:  Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child:  const Text("CẮM CỜ (SPACE)"),
                ),
              ),
              if (hasPressed) ...[
                const SizedBox(width:  10),
                IconButton(
                  onPressed: provider. reset,
                  icon: const Icon(Icons.refresh),
                ),
              ]
            ],
          );
        },
      ),
    );
  }
}

// CustomPainter giữ nguyên
class ScoreBarPainter extends CustomPainter {
  final List<double> markers;
  final double totalTime;

  ScoreBarPainter({
    required this.markers,
    required this.totalTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (totalTime <= 0 || markers.length < 6) return;

    final colors = [
      Colors.green,
      Colors.lightGreen,
      Colors.yellow,
      Colors.orange,
      Colors. redAccent,
    ];

    for (int i = 0; i < 5; i++) {
      final paint = Paint()..color = colors[i];
      double left = (markers[i] / totalTime) * size.width;
      double right = (markers[i + 1] / totalTime) * size.width;
      canvas.drawRect(Rect. fromLTRB(left, 0, right, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant ScoreBarPainter oldDelegate) {
    return oldDelegate. totalTime != totalTime ||
        oldDelegate.markers != markers;
  }
}
class MoPhongProvider extends ChangeNotifier {
  final MoPhong moPhong;
  late VideoPlayerController controller;
  late List<double> markers;

  bool isInitialized = false;
  bool hasPressed = false;
  int score = 0;
  double?  flagTime;

  MoPhongProvider({required this.moPhong}) {
    markers = moPhong. dapAn
        .split(',')
        .map((e) => double.parse(e.trim()))
        .toList();
    _initializeVideo();
  }

  void _initializeVideo() {
    final String fullUrl = 'http://10.0.2.2:5084${moPhong.videoUrl}';
    controller = VideoPlayerController.networkUrl(Uri.parse(fullUrl))
      ..initialize().then((_) {
        isInitialized = true;
        notifyListeners();
        controller.play();
      });
  }

  void onFlagPressed() {
    if (hasPressed || !isInitialized) return;

    // Pause video ngay lập tức
    controller.pause();

    hasPressed = true;
    flagTime = controller.value.position.inMilliseconds / 1000.0;
    score = _calculateScore(flagTime!);

    notifyListeners(); // ✅ Chỉ rebuild những widget cần thiết
  }

  int _calculateScore(double time) {
    try {
      if (time >= markers[0] && time < markers[1]) return 5;
      if (time >= markers[1] && time < markers[2]) return 4;
      if (time >= markers[2] && time < markers[3]) return 3;
      if (time >= markers[3] && time < markers[4]) return 2;
      if (time >= markers[4] && time < markers[5]) return 1;
    } catch (e) {
      print(e);
    }
    return 0;
  }

  void reset() {
    hasPressed = false;
    score = 0;
    flagTime = null;
    controller.seekTo(Duration.zero);
    controller.play();
    notifyListeners();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}