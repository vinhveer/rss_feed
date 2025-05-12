import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import '../settings_pages/page_settings.dart';

class PageVerifyOTP extends StatelessWidget {
  const PageVerifyOTP({super.key, required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Xác thực mã OTP"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OtpTextField(
            numberOfFields: 6,
            borderColor: const Color(0xFF512DA8),
            showFieldAsBox: true,
            onSubmit: (String verificationCode) async {
              final res = await Supabase.instance.client.auth.verifyOTP(
                email: email,
                token: verificationCode,
                type: OtpType.email,
              );
              if (!context.mounted) return;
              if (res.session != null && res.user != null) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const PageSettings()),
                      (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signInWithOtp(email: email);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã gửi lại mã OTP")),
              );
            },
            child: const Text("Gửi lại mã OTP"),
          ),
        ],
      ),
    );
  }
}