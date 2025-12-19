import 'package:damh_flutter/models/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/authenticate.dart';

class LoginScreen extends StatefulWidget{
  @override
  State<LoginScreen> createState() => LoginState();
}
class LoginState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  bool _isLoading = false; // Thêm biến loading

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
                  decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Nhập username"),
                  validator: (value) => (value == null || value.isEmpty) ? "Vui Lòng Nhập Username" : null,
                ),
                const SizedBox(height: 20),
                const Text("Password"),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passController,
                  obscureText: true, // Ẩn mật khẩu
                  decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Nhập mật khẩu"),
                  validator: (value) => (value == null || value.isEmpty) ? "Vui Lòng Nhập Mật Khẩu" : null,
                ),
                const SizedBox(height: 30),
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator() // Hiện loading khi đang gọi API
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
                    onPressed: _handleLogin,
                    child: const Text("Đăng Nhập"),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Bạn chưa có tài khoản? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/register");
                      },
                      child: const Text("Đăng ký tại đây"),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Tách hàm xử lý đăng nhập để code sạch hơn
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; }); // Bắt đầu loading

      try {
        final request = LoginRequest(
            username: userController.text,
            password: passController.text
        );

        // Đợi kết quả từ API
        final response = await Authenticate.login(request);

        if (response.status == true) {
          // Lưu token vào máy để các API sau dùng
          const storage = FlutterSecureStorage();
          await storage.write(key: 'jwt_token', value: response.token);

          if (mounted) {
            Navigator.pushReplacementNamed(context, "/home");
          }
        } else {
          // Đăng nhập thất bại (sai pass/user)
          _showError(response.message);
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