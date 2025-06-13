import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:rss_feed/pages/account_pages/page_reset_password.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class PageOTPForget extends StatefulWidget {
  const PageOTPForget({super.key, required this.email});
  final String email;

  @override
  State<PageOTPForget> createState() => _PageOTPForgetState();
}

class _PageOTPForgetState extends State<PageOTPForget> {
  bool _isLoading = false;
  bool _isResending = false;
  String _otpCode = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Xác thực mã OTP",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  
                  // Icon và tiêu đề
                  const Icon(
                    Icons.email_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Xác thực email',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  
                  Text(
                    'Chúng tôi đã gửi mã OTP 6 số tới email:\n${widget.email}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // OTP Input
                  Center(
                    child: OtpTextField(
                      numberOfFields: 6,
                      borderColor: Colors.grey.shade300,
                      focusedBorderColor: Theme.of(context).primaryColor,
                      showFieldAsBox: true,
                      borderWidth: 2,
                      borderRadius: BorderRadius.circular(8),
                      fieldWidth: 45,
                      fieldHeight: 55,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      onCodeChanged: (String code) {
                        _otpCode = code;
                      },
                      onSubmit: (String verificationCode) {
                        _verifyOTP(verificationCode);
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Nút xác nhận
                  FilledButton(
                    onPressed: _isLoading ? null : () => _verifyOTP(_otpCode),
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
                            'Xác nhận',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Nút gửi lại OTP
                  OutlinedButton(
                    onPressed: _isResending ? null : _resendOTP,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isResending
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Gửi lại mã OTP',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Text hướng dẫn
                  const Text(
                    'Không nhận được mã? Kiểm tra thư mục spam hoặc nhấn gửi lại.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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

  void _verifyOTP(String verificationCode) async {
    if (verificationCode.length != 6) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập đầy đủ 6 số',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final res = await Supabase.instance.client.auth.verifyOTP(
        email: widget.email,
        token: verificationCode,
        type: OtpType.email,
      );

      if (!mounted) return;

      if (res.session != null && res.user != null) {
        Get.snackbar(
          'Thành công',
          'Xác thực email thành công',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        
        Get.offAll(() => PageResetPassword(email: widget.email));
      } else {
        Get.snackbar(
          'Lỗi',
          'Mã OTP không chính xác',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Xác thực thất bại: ${e.toString()}',
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

  void _resendOTP() async {
    setState(() {
      _isResending = true;
    });

    try {
      await Supabase.instance.client.auth.signInWithOtp(email: widget.email);
      
      if (!mounted) return;
      
      Get.snackbar(
        'Thành công',
        'Đã gửi lại mã OTP tới email của bạn',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Gửi lại mã OTP thất bại: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }
}