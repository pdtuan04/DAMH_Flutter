import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/user.dart';
import '../../../services/user_api_service.dart';

class UserDetail extends StatefulWidget {
  final User user;

  const UserDetail({Key? key, required this.user}) : super(key: key);

  @override
  _UserDetailState createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail> {
  List<Role> _roles = [];
  String? _selectedRole;
  bool _isLoading = false;
  bool _isSaving = false;
  User? _userDetail; // Thông tin user đầy đủ từ API

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load cả user detail và roles
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load user detail với roles
      final userDetail = await UserApiService.getUserById(widget.user.id);
      
      // Load danh sách roles
      final roles = await UserApiService.getRoleList();
      
      setState(() {
        _userDetail = userDetail;
        _roles = roles;
        _selectedRole = userDetail.primaryRole;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateRole() async {
    if (_selectedRole == null || _selectedRole == _userDetail?.primaryRole) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có thay đổi nào')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final success = await UserApiService.setUserRole(
        widget.user.id,
        _selectedRole!,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật role thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật role thất bại!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng userDetail nếu đã load được, không thì dùng widget.user
    final displayUser = _userDetail ?? widget.user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Người Dùng'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _updateRole,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: displayUser.primaryRole == 'Admin'
                          ? Colors.red
                          : Colors.blue,
                      child: Text(
                        displayUser.username.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontSize: 40, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Thông tin cơ bản
                  _buildInfoCard(
                    'Thông tin cơ bản',
                    [
                      _buildInfoRow('ID', displayUser.id),
                      _buildInfoRow('Tên đăng nhập', displayUser.username),
                      _buildInfoRow('Email', displayUser.email),
                      if (displayUser.createAt != null)
                        _buildInfoRow(
                          'Ngày tạo',
                          DateFormat('dd/MM/yyyy HH:mm').format(displayUser.createAt!),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quản lý Role
                  _buildInfoCard(
                    'Phân quyền',
                    [
                      const Text(
                        'Role hiện tại:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      if (displayUser.roles != null && displayUser.roles!.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          children: displayUser.roles!.map((role) => Chip(
                            label: Text(role, style: const TextStyle(color: Colors.white)),
                            backgroundColor: role == 'Admin' ? Colors.red : Colors.green,
                          )).toList(),
                        )
                      else
                        const Text(
                          'Chưa có role',
                          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text(
                        'Thay đổi role:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _roles.map((role) {
                          return DropdownMenuItem<String>(
                            value: role.name,
                            child: Text(role.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedRole = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Nút lưu
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _updateRole,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Lưu Thay Đổi',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}