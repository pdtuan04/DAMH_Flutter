import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/register.dart';
import '../services/authenticate.dart';

class RegisterScreen extends StatefulWidget{
  @override
  State<RegisterScreen> createState() => _RegisterScreen();
}
class _RegisterScreen extends State<RegisterScreen>{
  final _formKey = GlobalKey<FormState>();
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Đăng Nhập"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(19),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView( // Nên bọc thêm cái này để tránh lỗi tràn màn hình khi hiện bàn phím
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Username"),
                const SizedBox(height: 10),
                TextFormField(
                  controller: userController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: "Nhập Username"),
                  validator: (value) =>
                  (value == null || value.isEmpty)
                      ? "Vui Lòng Nhập Username"
                      : null,
                ),
                const Text("Email"),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: "Nhập email"),
                  validator: (value) =>
                  (value == null || value.isEmpty)
                      ? "Vui Lòng Nhập Email"
                      : null,
                ),
                const SizedBox(height: 20),
                const Text("Password"),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passController,
                  obscureText: true, // Ẩn mật khẩu
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: "Nhập mật khẩu"),
                  validator: (value) =>
                  (value == null || value.isEmpty)
                      ? "Vui Lòng Nhập Mật Khẩu"
                      : null,
                ),

                const SizedBox(height: 30),
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator() // Hiện loading khi đang gọi API
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50)),
                    onPressed: _handleRegister,
                    child: const Text("Đăng Ký"),
                  ),
                )
              ],
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