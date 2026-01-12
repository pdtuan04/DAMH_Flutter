import 'package:flutter/material.dart';
import '../../../models/mo_phong.dart';
import '../../../services/mo_phong_api_service.dart';
import 'mo_phong_form_create.dart';
import 'mo_phong_detail.dart';
import 'mo_phong_delete.dart';

class QuanLyMoPhong extends StatefulWidget {
  const QuanLyMoPhong({Key? key}) : super(key: key);

  @override
  _QuanLyMoPhongState createState() => _QuanLyMoPhongState();
}

class _QuanLyMoPhongState extends State<QuanLyMoPhong> {
  List<MoPhong> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Tải dữ liệu từ API
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiMoPhongService.getAll();
      setState(() => _items = list);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'))
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Xóa mô phỏng
  void _delete(String id) {
    MoPhongDelete.showDeleteDialog(context, id, () {
      _loadData();
    });
  }

  // Xem chi tiết
  void _showDetail(MoPhong item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MoPhongDetail(moPhong: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Mô Phỏng'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _items.isEmpty
                  ? const Center(child: Text('Chưa có mô phỏng nào'))
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (ctx, index) {
                        final item = _items[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            title: Text(
                              item.noiDung,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Đáp án: ${item.dapAn}'),
                            leading: const Icon(
                              Icons.video_library,
                              color: Colors.blue,
                              size: 40,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Nút xem chi tiết
                                IconButton(
                                  icon: const Icon(Icons.visibility, color: Colors.green),
                                  onPressed: () => _showDetail(item),
                                  tooltip: 'Xem',
                                ),
                                // Nút sửa
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () async {
                                    final res = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MoPhongFormCreate(moPhong: item),
                                      ),
                                    );
                                    if (res == true) _loadData();
                                  },
                                  tooltip: 'Sửa',
                                ),
                                // Nút xóa
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _delete(item.id),
                                  tooltip: 'Xóa',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      // Nút thêm mới
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MoPhongFormCreate()),
          );
          if (res == true) _loadData();
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}