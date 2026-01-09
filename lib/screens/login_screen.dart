import 'package:damh_flutter/models/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/authenticate.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => LoginState();
}

class LoginState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true; // Để ẩn/hiện mật khẩu

  // Trong LoginState
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/log.jpg"), // Đường dẫn ảnh của bạn
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // Lớp phủ tối để làm nổi bật form
          color: Colors.black.withOpacity(0.4),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.traffic_rounded, size: 80, color: Colors.yellowAccent),
                  const SizedBox(height: 10),
                  const Text(
                    "ÔN THI GIẤY PHÉP LÁI XE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
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
                              "Đăng Nhập Hệ Thống",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: userController,
                              decoration: InputDecoration(
                                labelText: "Tên đăng nhập",
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              validator: (value) => (value == null || value.isEmpty) ? "Vui lòng nhập tên" : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: passController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                labelText: "Mật khẩu",
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () => setState(() => _obscureText = !_obscureText),
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              validator: (value) => (value == null || value.isEmpty) ? "Vui lòng nhập mật khẩu" : null,
                            ),
                            const SizedBox(height: 30),
                            _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 55),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _handleLogin,
                              child: const Text("VÀO THI NGAY", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, "/register"),
                    child: const Text(
                      "Chưa có tài khoản? Đăng ký tại đây",
                      style: TextStyle(color: Colors.white, decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
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

  // Giữ nguyên hàm _handleLogin của bạn
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });
      try {
        final request = LoginRequest(username: userController.text, password: passController.text);
        final response = await Authenticate.login(request);
        if (response.status == true) {
          const storage = FlutterSecureStorage();
          await storage.write(key: 'jwt_token', value: response.token);
          if (mounted) {
            if (response.roles.contains("Admin")) {
              Navigator.pushReplacementNamed(context, "/admin");
            } else {
              Navigator.pushReplacementNamed(context, "/home");
            }
          }
        } else {
          _showError(response.message);
        }
      } catch (e) {
        _showError(e.toString().replaceAll("Exception: ", ""));
      } finally {
        if (mounted) setState(() { _isLoading = false; });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
    );
  }
}