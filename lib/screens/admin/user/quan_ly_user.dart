import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../services/user_api_service.dart';
import 'user_detail.dart';

class QuanLyUser extends StatefulWidget {
  const QuanLyUser({Key? key}) : super(key: key);

  @override
  _QuanLyUserState createState() => _QuanLyUserState();
}

class _QuanLyUserState extends State<QuanLyUser> {
  List<User> _users = [];
  int _totalCount = 0;
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await UserApiService.getPagedUsers(
        page: _currentPage,
        pageSize: _pageSize,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
      
      setState(() {
        _users = response.users;
        _totalCount = response.totalCount;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _search() {
    setState(() {
      _searchQuery = _searchController.text;
      _currentPage = 1;
    });
    _loadData();
  }

  void _nextPage() {
    if (_currentPage * _pageSize < _totalCount) {
      setState(() => _currentPage++);
      _loadData();
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() => _currentPage--);
      _loadData();
    }
  }

  void _showUserDetail(User user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserDetail(user: user)),
    );
    
    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (_totalCount / _pageSize).ceil();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Người Dùng'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo tên hoặc email...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('Tìm', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),

          // User list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: _users.isEmpty
                        ? const Center(child: Text('Không có người dùng nào'))
                        : ListView.builder(
                            itemCount: _users.length,
                            itemBuilder: (ctx, index) {
                              final user = _users[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: user.primaryRole == 'Admin' 
                                        ? Colors.red 
                                        : Colors.blue,
                                    child: Text(
                                      user.username.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(
                                    user.username,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(user.email),
                                      if (user.roles != null && user.roles!.isNotEmpty)
                                        Chip(
                                          label: Text(
                                            user.primaryRole,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: user.primaryRole == 'Admin'
                                              ? Colors.red
                                              : Colors.green,
                                          padding: const EdgeInsets.all(2),
                                        ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                                    onPressed: () => _showUserDetail(user),
                                  ),
                                  onTap: () => _showUserDetail(user),
                                ),
                              );
                            },
                          ),
                  ),
          ),

          // Pagination
          if (_totalCount > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng: $_totalCount người dùng',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _currentPage > 1 ? _previousPage : null,
                      ),
                      Text('$_currentPage / $totalPages'),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _currentPage < totalPages ? _nextPage : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}