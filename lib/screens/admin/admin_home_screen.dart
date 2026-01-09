import 'package:flutter/material.dart';
import '../../services/authenticate.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutConfirmDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildAdminCard(
              context,
              'Quản lý Loại Bằng Lái',
              Icons.card_membership,
              Colors.orange,
                  () => Navigator.pushNamed(context, '/admin/loai-bang-lai'),
            ),
            _buildAdminCard(
              context,
              'Quản lý Chủ Đề',
              Icons.topic,
              Colors.green,
                  () => Navigator.pushNamed(context, '/admin/chu-de'),
            ),
            _buildAdminCard(
              context,
              'Quản lý Câu Hỏi',
              Icons.question_answer,
              Colors.blue,
                  () => Navigator.pushNamed(context, '/admin/cau-hoi'),
            ),
            _buildAdminCard(
              context,
              'Quản lý Bài Thi',
              Icons.assignment,
              Colors.purple,
                  () => Navigator.pushNamed(context, '/admin/bai-thi'),
            ),
          ],
        ),
      ),
    );
  }

  /// Card chức năng admin
  Widget _buildAdminCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog xác nhận đăng xuất
  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () async {
                await TokenService.deleteToken();
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );
  }
}
