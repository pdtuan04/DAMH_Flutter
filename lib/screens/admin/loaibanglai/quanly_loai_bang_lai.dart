import 'package:flutter/material.dart';
import '../../../models/loai_bang_lai.dart';
import '../../../services/loai_bang_lai_api.dart';
import 'loai_bang_lai_form_create.dart';
import 'loai_bang_lai_detail.dart';
import 'loai_bang_lai_delete.dart';

class QuanLyLoaiBangLai extends StatefulWidget {
  const QuanLyLoaiBangLai({Key? key}) : super(key: key);

  @override
  _QuanLyLoaiBangLaiState createState() => _QuanLyLoaiBangLaiState();
}

class _QuanLyLoaiBangLaiState extends State<QuanLyLoaiBangLai> {
  List<LoaiBangLai> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiLoaiBangLaiService.getAll();
      setState(() => _items = list);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _delete(String id) {
    LoaiBangLaiDelete.showDeleteDialog(context, id, () {
       _loadData(); 
    });
  }

  void _showDetail(LoaiBangLai item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LoaiBangLaiDetail(loaiBangLai: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản Lý Loại Bằng Lái')),
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
                title: Text(item.tenLoai),
                subtitle: Text('Thời gian: ${item.thoiGianThi}p - Điểm đạt: ${item.diemToiThieu}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.green),
                        onPressed: () => _showDetail(item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => LoaiBangLaiFormCreate(loaiBangLai: item)),
                          );
                          if (res == true) _loadData();
                        },
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
            MaterialPageRoute(builder: (_) => const LoaiBangLaiFormCreate()),
          );
          if (res == true) _loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
