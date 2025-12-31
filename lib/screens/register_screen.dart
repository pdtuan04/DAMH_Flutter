import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/register.dart';
import '../services/authenticate.dart';

class RegisterScreen extends StatefulWidget{
  @override
  State<RegisterScreen> createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  // 1. Thêm controller cho nhập lại mật khẩu
  final TextEditingController confirmPassController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true;
  bool _obscureConfirmText = true; // Ẩn hiện cho ô nhập lại

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/res.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.4),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.app_registration_rounded, size: 80, color: Colors.greenAccent),
                  const SizedBox(height: 10),
                  const Text(
                    "TẠO TÀI KHOẢN MỚI",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "Thông Tin Đăng Ký",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                            ),
                            const SizedBox(height: 20),
                            // Username
                            TextFormField(
                              controller: userController,
                              decoration: InputDecoration(
                                labelText: "Tên người dùng",
                                prefixIcon: const Icon(Icons.person_add),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              validator: (value) => (value == null || value.isEmpty) ? "Vui lòng nhập Username" : null,
                            ),
                            const SizedBox(height: 15),
                            // Email
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: "Email",
                                prefixIcon: const Icon(Icons.email),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              validator: (value) => (value == null || value.isEmpty) ? "Vui lòng nhập Email" : null,
                            ),
                            const SizedBox(height: 15),
                            // Password
                            TextFormField(
                              controller: passController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                labelText: "Mật khẩu",
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () => setState(() => _obscureText = !_obscureText),
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              validator: (value) => (value == null || value.isEmpty) ? "Vui lòng nhập mật khẩu" : null,
                            ),
                            const SizedBox(height: 15),

                            // 2. Ô NHẬP LẠI MẬT KHẨU
                            TextFormField(
                              controller: confirmPassController,
                              obscureText: _obscureConfirmText,
                              decoration: InputDecoration(
                                labelText: "Nhập lại mật khẩu",
                                prefixIcon: const Icon(Icons.lock_reset),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureConfirmText ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () => setState(() => _obscureConfirmText = !_obscureConfirmText),
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return "Vui lòng nhập lại mật khẩu";
                                if (value != passController.text) return "Mật khẩu không khớp";
                                return null;
                              },
                            ),

                            const SizedBox(height: 30),
                            _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 55),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _handleRegister,
                              child: const Text("ĐĂNG KÝ NGAY", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Đã có tài khoản? Quay lại đăng nhập",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; }); // Bắt đầu loading

      try {
        final request = RegisterRequest(
          username: userController.text,
          password: passController.text,
          email: emailController.text,
        );

        // Đợi kết quả từ API
        final response = await Authenticate.register(request);

        if (response == true) {
          if (!mounted) return;

          showDialog(
            context: context,
            barrierDismissible: false, // không bấm ra ngoài
            builder: (context) {
              return AlertDialog(
                title: const Text("Thành công"),
                content: const Text("Đăng ký thành công, vui lòng đăng nhập lại"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // đóng dialog
                      Navigator.pushReplacementNamed(context, "/login");
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        } else {
          // Đăng nhập thất bại (sai pass/user)
          _showError("Có lỗi khi đăng ký");
        }
      } catch (e) {
        // Lỗi kết nối hoặc lỗi Exception từ Service
        _showError(e.toString().replaceAll("Exception: ", ""));
      } finally {
        if (mounted) {
          setState(() { _isLoading = false; }); // Tắt loading
        }
      }
    }
  }
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}