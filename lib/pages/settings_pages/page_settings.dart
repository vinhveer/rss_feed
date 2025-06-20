import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/controllers/app_controller.dart';
import 'package:rss_feed/controllers/color_controller.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import '../../app.dart';
import '../../controllers/auth_controller.dart';


class PageSettings extends StatelessWidget {
  const PageSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find<AppController>();
    final ColorController colorController = Get.find<ColorController>();

    return Scaffold(
      appBar: AppBar(
          title: Text("Cài đặt", style: TextStyle(fontWeight: FontWeight.w600),)
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card đăng nhập
              InkWell(
                onTap: () => appController.goToLoginPage(),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person, size: 30, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Xin chào", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
                            Text(
                              (Supabase.instance.client.auth.currentUser?.email?.isNotEmpty ?? false)
                                  ? Supabase.instance.client.auth.currentUser!.email!
                                  : 'Vui lòng đăng nhập để đồng bộ dữ liệu',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'HIỂN THỊ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text('Chế độ hiển thị'),
                subtitle: Text(colorController.getCurrentMode()),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => appController.goToThemeModeSettingPage(),
              )),
              Obx(() => ListTile(
                leading: const Icon(Icons.color_lens),
                title: const Text('Chọn màu'),
                subtitle: Text(colorController.getCurrentColorName()),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => appController.goToColorSchemeSettingsPage(),
              )),

              const SizedBox(height: 16),
              (Supabase.instance.client.auth.currentUser?.email?.isNotEmpty ?? false)
                  ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'HÀNH ĐỘNG ĐỐI VỚI TÀI KHOẢN',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.password_rounded),
                    title: const Text('Thay đổi mật khẩu'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => appController.goToChangePassword(),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Đăng xuất'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      Supabase.instance.client.auth.currentUser?.email;

                      final authController = Get.find<AuthController>();

                      await authController.signOut();

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã đăng xuất')),
                      );
                      Get.offAll(() => App());
                      appController.changePage(3);
                    },
                  ),
                ],
              )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
