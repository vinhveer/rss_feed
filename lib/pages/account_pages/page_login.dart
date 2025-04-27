import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/controllers/app_controller.dart';
import 'package:rss_feed/controllers/auth_controller.dart';
import 'package:rss_feed/controllers/color_controller.dart';

class PageLogin extends StatefulWidget {
  const PageLogin({super.key});

  @override
  State<PageLogin> createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;

  // Controllers
  final colorController = ColorController();
  final AuthController _authController = Get.find<AuthController>();
  final appController = AppController();

  void _handleEmailSignIn() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng điền đầy đủ email và mật khẩu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await _authController.signInWithEmail(email, password);
      Get.back(); // Quay về trang trước đó sau khi đăng nhập thành công
    } catch (e) {
      Get.snackbar(
        'Lỗi đăng nhập',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _handleEmailSignUp() {
    appController.goToSignUp();
  }

  void _handleGoogleSignIn() async {
    try {
      await _authController.signInWithGoogle();
      Get.back(); // Quay về trang trước đó sau khi đăng nhập thành công
    } catch (e) {
      Get.snackbar(
        'Lỗi đăng nhập',
        'Không thể đăng nhập với Google: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = colorController.currentSwatch;

    return Scaffold(
      appBar: AppBar(
          title: const Text(
            "Đăng nhập",
            style: TextStyle(fontWeight: FontWeight.w600),
          )
      ),
      body: Obx(() => Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên đăng nhập với floating label
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mật khẩu với nhãn nổi và nút hiển thị tích hợp
                  TextField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      labelText: "Mật khẩu",
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primary, width: 2),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                        icon: Icon(
                          _showPassword ? Icons.visibility_off : Icons.visibility,
                          color: primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nút đăng nhập
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleEmailSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Đăng nhập"),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nút tạo tài khoản mới
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _handleEmailSignUp,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primary,
                        side: BorderSide(color: primary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Tạo tài khoản mới"),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Đăng nhập bằng Google
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _handleGoogleSignIn,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Tiếp tục với Google"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quên mật khẩu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                        },
                        child: Text(
                          "Quên mật khẩu?",
                          style: TextStyle(color: primary),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          if (_authController.isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      )),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}