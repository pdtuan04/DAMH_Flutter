import 'package:flutter/material.dart';
import 'package:damh_flutter/models/cau_hoi.dart';
import '../../../services/cau_hoi_service_api.dart';
import 'cau_hoi_form_create.dart';
import 'cau_hoi_detail.dart';
import 'cau_hoi_delete.dart';

class QuanLyCauHoi extends StatefulWidget {
  const QuanLyCauHoi({Key? key}) : super(key: key);

  @override
  _QuanLyCauHoiState createState() => _QuanLyCauHoiState();
}

class _QuanLyCauHoiState extends State<QuanLyCauHoi> {
  List<CauHoi> _cauHois = [];
  bool _isLoading = false;
  int _page = 0; 
  final int _pageSize = 20;
  bool _hasMore = true;
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData(reset: true);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (_hasMore && !_isLoading) {
        _loadData();
      }
    }
  }

  Future<void> _loadData({bool reset = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    if (reset) {
      _page = 0; 
      _cauHois = [];
      _hasMore = true;
    }

    try {
      final nextPage = _page + 1; 
      final result = await ApiCauHoiService.getPagedCauHoi(nextPage, _pageSize, search: _searchQuery);
      final List<CauHoi> news = result['items'];
      final int total = result['totalCount'];

      setState(() {
        _cauHois.addAll(news);
        _page = nextPage;
        _hasMore = _cauHois.length < total;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _deleteCauHoi(String id) {
    CauHoiDelete.showDeleteDialog(context, id, () {
       _loadData(reset: true);
    });
  }

  void _openForm([CauHoi? cauHoi]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CauHoiFormCreate(cauHoi: cauHoi)),
    );
    if (result == true) {
      _loadData(reset: true);
    }
  }

  void _showDetail(CauHoi cauHoi) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CauHoiDetail(cauHoi: cauHoi)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Câu Hỏi'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm câu hỏi...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    _loadData(reset: true);
                  },
                ),
              ),
              onSubmitted: (val) {
                setState(() => _searchQuery = val);
                _loadData(reset: true);
              },
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(reset: true),
        child: _cauHois.isEmpty && !_isLoading
            ? const Center(child: Text('Không có dữ liệu'))
            : ListView.builder(
          controller: _scrollController,
          itemCount: _cauHois.length + (_hasMore ? 1 : 0),
          itemBuilder: (ctx, index) {
            if (index == _cauHois.length) {
              return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
            }
            final item = _cauHois[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text(item.noiDung, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text('Đáp án: ${item.dapAnDung} | Liệt: ${item.diemLiet ? "Có" : "Không"}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.green),
                        onPressed: () => _showDetail(item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _openForm(item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCauHoi(item.id),
                      ),
                    ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
