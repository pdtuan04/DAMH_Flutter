import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:damh_flutter/screens/on_tap_theo_chu_de_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/authenticate.dart';
import 'danh_sach_bai_thi_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  bool _notiShown = false;

  final List<Widget> _screens = const [
    HomeScreen(),
    DanhSachBaiThiScreen(),
    OnTapTheoChuDeScreen(),
    ProfileScreen(),
  ];

  final List<String> _titles = const [
    'Trang chủ',
    'Thi Thử',
    'OnTap',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();

    /// Hiện snackbar sau khi build xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_notiShown) {
        _notiShown = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Success')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.indigo, // Đổi màu Indigo cho đồng bộ chủ đề giao thông
        foregroundColor: Colors.white,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: _screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Thi thử'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Ôn tập'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Nền hơi xanh nhạt hiện đại
      body: FutureBuilder<User>(
        future: Authenticate.userProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.indigo));
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final user = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(user),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("THÔNG TIN TÀI KHOẢN",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                      const SizedBox(height: 16),
                      _buildInfoCard(Icons.person_outline_rounded, "Tên tài khoản", user.username, Colors.blue),
                      _buildInfoCard(Icons.email_outlined, "Email liên kết", user.email, Colors.orange),
                      const SizedBox(height: 32),
                      const Text("HÀNH ĐỘNG",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                      const SizedBox(height: 16),
                      _buildActionTile(Icons.history_rounded, "Lịch sử thi", () {}),
                      _buildActionTile(Icons.settings_outlined, "Cài đặt ứng dụng", () {}),

                      const SizedBox(height: 40),
                      _buildLogoutButton(context),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET CẤU TRÚC ---

  Widget _buildHeader(User user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3F51B5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Text(user.username[0].toUpperCase(),
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.indigo)),
            ),
          ),
          const SizedBox(height: 16),
          Text(user.username,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(user.email,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF263238))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.indigo.shade300),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Colors.redAccent),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () async {
          await TokenService.deleteToken();
          Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
        },
        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
        label: const Text("Đăng xuất tài khoản",
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          const Text("Phiên đăng nhập đã hết hạn"),
          TextButton(onPressed: () => Authenticate.userProfile(), child: const Text("Thử lại"))
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget
{
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();

}
class _HomeScreenState extends State<HomeScreen> {
  int _current = 0;
  final List<String> imgList = [
    'assets/images/aqua.jpg',
    'assets/images/my_lucy.jpg',
    'assets/images/word.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSlider(),

          // Tiêu đề mục chính với icon nhỏ xinh
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.indigo, size: 20),
                const SizedBox(width: 8),
                const Text("Hành trang ôn thi",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
              ],
            ),
          ),

          // 1. Thẻ Hành động chính (Dùng màu Indigo Deep)
          _buildMainActionCard(),

          const SizedBox(height: 16),

          // 2. Grid Menu với 4 màu sắc chủ đạo khác nhau hoàn toàn
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.3,
              children: [
                _buildColorfulCard(
                  icon: Icons.shuffle_rounded,
                  title: "Đề ngẫu nhiên",
                  sub: "Thử thách mới",
                  baseColor: Colors.orange,
                  onTap: () {

                  },
                ),
                _buildColorfulCard(
                  icon: Icons.menu_book_rounded,
                  title: "Ôn tập theo chủ đề",
                  sub: "Ôn câu hỏi theo chủ đề",
                  baseColor: Colors.blueAccent,
                  onTap: () {
                    final homeState = context.findAncestorStateOfType<_HomeState>();
                    if (homeState != null) {
                      homeState._onItemTapped(2);
                    }
                  },
                ),
                _buildColorfulCard(
                  icon: Icons.videogame_asset_rounded,
                  title: "Ôn mô phỏng",
                  sub: "120 tình huống",
                  baseColor: Colors.purpleAccent,
                  onTap: () {

                  },
                ),
                _buildColorfulCard(
                  icon: Icons.tips_and_updates_rounded,
                  title: "Ôn toàn bộ câu hỏi",
                  sub: "Ôn toàn bộ câu hỏi theo loại bằng lái",
                  baseColor: Colors.teal,
                  onTap: () {

                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Mục CÂU HAY SAI - Gradient Đỏ rực rỡ
          _buildSystemMistakeCard(),

          const SizedBox(height: 25),
        ],
      ),
    );
  }

  // --- WIDGETS CHI TIẾT ---

  Widget _buildColorfulCard({
    required IconData icon,
    required String title,
    required String sub,
    required Color baseColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor.withOpacity(0.15),
            baseColor.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: baseColor.withOpacity(0.2), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Thu nhỏ padding một chút
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: baseColor.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4))
                      ]),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 10),
                // Dùng Flexible hoặc Expanded để tránh tràn chữ theo chiều dọc
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1, // Giới hạn 1 dòng cho tiêu đề
                    overflow: TextOverflow.ellipsis, // Cắt bằng dấu ...
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14, // Giảm nhẹ font size nếu cần
                        color: baseColor.withOpacity(0.9)),
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    sub,
                    maxLines: 2, // Giới hạn tối đa 2 dòng cho mô tả
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 10,
                        color: baseColor.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                        height: 1.2), // Khoảng cách dòng hẹp lại
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSystemMistakeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFFF44336), Color(0xFFB71C1C)],
            ),
            boxShadow: [
              BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))
            ]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
              child: const Icon(Icons.whatshot_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Top 20 câu hay sai",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                  Text("Dữ liệu từ toàn bộ người dùng hệ thống",
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: CarouselSlider(
        items: imgList.map((item) => ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(item, fit: BoxFit.cover, width: double.infinity),
        )).toList(),
        options: CarouselOptions(
          height: 180,
          autoPlay: true,
          viewportFraction: 0.9,
          enlargeCenterPage: true,
          onPageChanged: (index, _) => setState(() => _current = index),
        ),
      ),
    );
  }

  Widget _buildMainActionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3F51B5)],
        ),
        boxShadow: [
          BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Thi thử ngay", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text("Cập nhật bộ đề mới nhất 2026", style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final homeState = context.findAncestorStateOfType<_HomeState>();
              if (homeState != null) {
                homeState._onItemTapped(1); // Chuyển sang index 1 (Thi Thử)
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.indigo,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(15),
            ),
            child: const Icon(Icons.play_arrow_rounded, size: 30),
          )
        ],
      ),
    );
  }
}