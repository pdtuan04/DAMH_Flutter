import 'package:flutter/material.dart';
import '../../../models/bai_thi.dart';
import '../../../services/bai_thi_api.dart';
import 'bai_thi_form_create.dart';
import 'bai_thi_detail.dart';
import 'bai_thi_delete.dart';

class QuanLyBaiThi extends StatefulWidget {
  const QuanLyBaiThi({Key? key}) : super(key: key);

  @override
  _QuanLyBaiThiState createState() => _QuanLyBaiThiState();
}

class _QuanLyBaiThiState extends State<QuanLyBaiThi> {
  List<BaiThi> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiBaiThiService.getAll();
      setState(() => _items = list);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDetail(BaiThi item) {
    showDialog(
      context: context,
      builder: (_) => BaiThiDetail(baiThi: item),
    );
  }

  void _delete(String id) {
    BaiThiDelete.showDeleteDialog(context, id, () {
      _loadData(); // Refresh on success
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản Lý Bài Thi')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (ctx, index) {
            final item = _items[index];
            return Card(
              child: ListTile(
                onTap: () => _showDetail(item),
                title: Text(item.tenBaiThi),
                subtitle: Text('Số câu: ${item.chiTietBaiThis.length}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.green),
                        onPressed: () => _showDetail(item)
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _delete(item.id),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BaiThiFormCreate()),
          );
          if (res == true) _loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
