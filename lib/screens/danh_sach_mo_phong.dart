import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import '../models/mo_phong.dart';
import '../services/mo_phong_api_service.dart';
import 'mo_phong_screen.dart';

class DanhSachMoPhongScreen extends StatefulWidget {
  const DanhSachMoPhongScreen({super.key});

  @override
  State<DanhSachMoPhongScreen> createState() => _DanhSachMoPhongScreenState();
}

class _DanhSachMoPhongScreenState extends State<DanhSachMoPhongScreen> {
  late Future<List<MoPhong>> _moPhongFuture;

  @override
  void initState() {
    super.initState();
    _moPhongFuture = ApiMoPhongService.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F2F5), // Chuyển màu nền vào đây
      child: FutureBuilder<List<MoPhong>>(
        future: _moPhongFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.purple));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Không tìm thấy tình huống nào"));
          }

          final list = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return _buildMoPhongCard(item, index + 1);
            },
          );
        },
      ),
    );
  }

  Widget _buildMoPhongCard(MoPhong item, int displayIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              "$displayIndex",
              style: const TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          "Tình huống $displayIndex",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            item.noiDung,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MoPhongScreen(moPhong: item),
            ),
          );
        },
      ),
    );
  }
}