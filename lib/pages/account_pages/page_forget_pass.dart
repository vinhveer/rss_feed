import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/pages/account_pages/page_otp_forget_pass.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rss_feed/controllers/color_controller.dart';

class PageForgetPass extends StatefulWidget {
  const PageForgetPass({super.key});

  @override
  State<PageForgetPass> createState() => _PageForgotPasswordState();
}

class _PageForgotPasswordState extends State<PageForgetPass> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  final colorController = Get.find<ColorController>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quên mật khẩu', 
          style: TextStyle(fontWeight: FontWeight.w600)
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    
                    // Icon và tiêu đề
                    const Icon(
                      Icons.lock_reset,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Đặt lại mật khẩu',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    const Text(
                      'Nhập địa chỉ email đã đăng ký để nhận mã OTP đặt lại mật khẩu.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        hintText: "Nhập email của bạn",
                        prefixIcon: const Icon(Icons.email_outlined),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        if (!value.contains('@')) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Nút gửi OTP
                    FilledButton(
                      onPressed: _isLoading ? null : _sendResetLink,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Gửi mã OTP',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Nút quay lại
                    TextButton(
                      onPressed: _isLoading ? null : () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: const Text(
                        'Quay lại đăng nhập',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void _sendResetLink() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final email = _emailController.text.trim();
        // Gửi yêu cầu đặt lại mật khẩu
        await Supabase.instance.client.auth.resetPasswordForEmail(email);

        // Thông báo thành công
        Get.snackbar(
          'Thành công',
          'Mã OTP đã được gửi tới email của bạn',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        // Chuyển tới trang nhập OTP
        Get.to(() => PageOTPForget(email: email));

      } catch (e) {
        // Thông báo lỗi khi gửi OTP thất bại
        Get.snackbar(
          'Lỗi',
          'Gửi mã OTP thất bại: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}