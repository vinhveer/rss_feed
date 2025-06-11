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
        title: const Text('Quên mật khẩu', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nhập địa chỉ email đã đăng ký để nhận liên kết đặt lại mật khẩu.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              // Email
              const Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Nhập email của bạn',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              const SizedBox(height: 30),
              // Nút gửi liên kết
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendResetLink,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                    'Gửi OTP đặt lại mật khẩu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
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
          'OTP đặt lại mật khẩu đã được gửi tới email của bạn',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.to(() => PageOTPForget(email: email));

        // Quay lại màn hình đăng nhập sau 1 giây
        await Future.delayed(const Duration(seconds: 1));
        Get.back(); // Quay lại màn hình đăng nhập hoặc trang trước
      } catch (e) {
        // Thông báo lỗi khi gửi OTP thất bại
        Get.snackbar(
          'Lỗi',
          'Gửi OTP thất bại: ${e.toString()}',
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
