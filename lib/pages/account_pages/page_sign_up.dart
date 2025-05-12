import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/pages/account_pages/page_otp_sign_up.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rss_feed/controllers/color_controller.dart';

class PageSignUp extends StatefulWidget {
  const PageSignUp({super.key});

  @override
  State<PageSignUp> createState() => _PageSignUpState();
}

class _PageSignUpState extends State<PageSignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _acceptTerms = false;
  final RxBool isLoading = false.obs;

  final colorController = ColorController();
  final _formKey = GlobalKey<FormState>();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập email';
    if (!GetUtils.isEmail(value)) return 'Email không hợp lệ';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu';
    if (value != _passwordController.text) return 'Mật khẩu xác nhận không khớp';
    return null;
  }

  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      Get.snackbar('Lỗi', 'Vui lòng đồng ý với điều khoản sử dụng');
      return;
    }

    isLoading.value = true;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user != null) {
        Get.to(() => PageVerifyOTP(email: email));
      }
    } catch (e) {
      Get.snackbar('Lỗi đăng ký', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = colorController.currentSwatch;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tạo tài khoản mới", style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: Obx(() => Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    decoration: InputDecoration(
                      labelText: "Email",
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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

                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    validator: _validatePassword,
                    decoration: InputDecoration(
                      labelText: "Mật khẩu",
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primary, width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword ? Icons.visibility_off : Icons.visibility,
                          color: primary,
                        ),
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_showConfirmPassword,
                    validator: _validateConfirmPassword,
                    decoration: InputDecoration(
                      labelText: "Xác nhận mật khẩu",
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primary, width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          color: primary,
                        ),
                        onPressed: () =>
                            setState(() => _showConfirmPassword = !_showConfirmPassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  CheckboxListTile(
                    value: _acceptTerms,
                    onChanged: (val) => setState(() => _acceptTerms = val ?? false),
                    title: const Text('Tôi đồng ý với điều khoản sử dụng',
                        style: TextStyle(fontSize: 14)),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Tạo tài khoản"),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primary,
                        side: BorderSide(color: primary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Đã có tài khoản? Đăng nhập"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading.value)
            Container(
              color: Colors.black,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      )),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
