import 'package:flutter/material.dart';
import '../../../models/chu_de.dart';
import '../../../services/chu_de_service_api.dart';
import 'chu_de_form_create.dart';
import 'chu_de_detail.dart';
import 'chu_de_delete.dart';

class QuanLyChuDe extends StatefulWidget {
  const QuanLyChuDe({Key? key}) : super(key: key);

  @override
  _QuanLyChuDeState createState() => _QuanLyChuDeState();
}

class _QuanLyChuDeState extends State<QuanLyChuDe> {
  List<ChuDe> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiChuDeService.getAll();
      setState(() => _items = list);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _delete(String id) {
    ChuDeDelete.showDeleteDialog(context, id, () {
       _loadData();
    });
  }

  void _showDetail(ChuDe item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChuDeDetail(chuDe: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản Lý Chủ Đề')),
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
                title: Text(item.tenChuDe),
                subtitle: Text(item.moTa),
                leading: item.imageUrl != null
                    ? Image.network(item.imageUrl!, width: 50, height: 50, errorBuilder: (_,__,___) => const Icon(Icons.error))
                    : const Icon(Icons.topic),
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
                          MaterialPageRoute(builder: (_) => ChuDeFormCreate(chuDe: item)),
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
            MaterialPageRoute(builder: (_) => const ChuDeFormCreate()),
          );
          if (res == true) _loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
