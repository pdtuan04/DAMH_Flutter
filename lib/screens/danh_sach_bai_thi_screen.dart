import 'package:damh_flutter/screens/lam_bai_thi_screen.dart';
import 'package:flutter/material.dart';
import '../models/bai_thi.dart';
import '../services/bai_thi_api.dart';

class DanhSachBaiThiScreen extends StatefulWidget {
  const DanhSachBaiThiScreen({super.key});

  @override
  State<DanhSachBaiThiScreen> createState() => _DanhSachBaiThiScreenState();
}

class _DanhSachBaiThiScreenState extends State<DanhSachBaiThiScreen> {
  late Future<List<BaiThi>> _baiThiFuture;

  @override
  void initState() {
    super.initState();
    _loadBaiThi();
  }

  void _loadBaiThi() {
    setState(() {
      _baiThiFuture = ApiBaiThiService.getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách bài thi'),
      ),

      body: FutureBuilder<List<BaiThi>>(
        future: _baiThiFuture,
        builder: (context, snapshot) {

          // 1️⃣ Đang loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải danh sách bài thi...'),
                ],
              ),
            );
          }

          // 2️⃣ Có lỗi
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadBaiThi,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3️⃣ Không có dữ liệu
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có bài thi nào',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // 4️⃣ Có dữ liệu
          final baiThis = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: baiThis.length,
            itemBuilder: (context, index) {
              final baiThi = baiThis[index];

              return Card(
                elevation: 2,
                margin:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),

                  // Tên bài thi
                  title: Text(
                    baiThi.tenBaiThi,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  // Số câu hỏi
                  subtitle: Text(
                    'Số câu hỏi: ${baiThi.chiTietBaiThis.length}',
                  ),

                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                  onTap: () {
                    // TODO: chuyển sang màn chi tiết bài thi
                    // Navigator.push(...)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LamBaiThiScreen(baiThiId: baiThi.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
