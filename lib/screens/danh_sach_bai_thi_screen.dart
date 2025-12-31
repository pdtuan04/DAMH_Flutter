import 'package:flutter/material.dart';
import '../models/bai_thi.dart';
import '../models/loai_bang_lai.dart';
import '../services/bai_thi_api.dart';
import '../services/loai_bang_lai_api.dart';
import 'lam_bai_thi_screen.dart';

class DanhSachBaiThiScreen extends StatefulWidget {
  const DanhSachBaiThiScreen({super.key});

  @override
  State<DanhSachBaiThiScreen> createState() => _DanhSachBaiThiScreenState();
}

class _DanhSachBaiThiScreenState extends State<DanhSachBaiThiScreen> {
  late Future<List<BaiThi>> _baiThiFuture;
  late Future<List<LoaiBangLai>> _loaiBangLaiFuture;
  String? _selectedLoaiBangLaiId;

  @override
  void initState() {
    super.initState();
    _loadAllBaiThi();
    _loadAllLoaiBangLai();
  }

  void _loadAllBaiThi() {
    setState(() {
      _selectedLoaiBangLaiId = null;
      _baiThiFuture = ApiBaiThiService.getAll();
    });
  }

  void _loadAllLoaiBangLai() {
    _loaiBangLaiFuture = ApiLoaiBangLaiService.getAll();
  }

  void _loadBaiThiByLoaiBangLai(String idLoaiBangLai) {
    setState(() {
      _selectedLoaiBangLaiId = idLoaiBangLai;
      _baiThiFuture = ApiBaiThiService.getByLoaiBangLaiId(idLoaiBangLai);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Nền xám nhạt cho chuyên nghiệp
      body: Column(
        children: [
          // Phần Combobox lọc bài thi
          _buildFilterSection(),

          // Danh sách bài thi
          Expanded(child: _buildListBaiThi()),
        ],
      ),
    );
  }

  // Widget xây dựng bộ lọc Dropdown
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: FutureBuilder<List<LoaiBangLai>>(
        future: _loaiBangLaiFuture,
        builder: (context, snapshot) {
          // Khởi tạo danh sách mặc định
          List<DropdownMenuItem<String>> menuItems = [
            const DropdownMenuItem(value: null, child: Text("Tất cả bài thi")),
          ];

          if (snapshot.hasError) {
            return Text("Lỗi tải hạng xe"); // Hiển thị nếu có lỗi API
          }

          if (snapshot.hasData) {
            // Thêm các hạng xe lấy được từ API
            menuItems.addAll(snapshot.data!.map((loai) {
              return DropdownMenuItem(
                  value: loai.id,
                  child: Text("Hạng ${loai.tenLoai}")
              );
            }).toList());
          }

          return DropdownButtonFormField<String>(
            // ... giữ nguyên các phần decoration
            value: _selectedLoaiBangLaiId,
            items: menuItems,
            onChanged: (value) {
              if (value == null) {
                _loadAllBaiThi();
              } else {
                _loadBaiThiByLoaiBangLai(value);
              }
            },
          );
        },
      ),
    );
  }

  // Widget xây dựng danh sách bài thi bằng FutureBuilder
  Widget _buildListBaiThi() {
    return FutureBuilder<List<BaiThi>>(
      future: _baiThiFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có bài thi nào cho hạng này.'));
        }

        final baiThis = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: baiThis.length,
          itemBuilder: (context, index) {
            final baiThi = baiThis[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 3,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.assignment, color: Colors.indigo),
                ),
                title: Text(
                  baiThi.tenBaiThi,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text('Số lượng: ${baiThi.chiTietBaiThis.length} câu hỏi'),
                    Text('Thời gian: 20 phút', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
                trailing: const Icon(Icons.play_circle_fill, color: Colors.orange, size: 35),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LamBaiThiScreen(baiThiId: baiThi.id)),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}