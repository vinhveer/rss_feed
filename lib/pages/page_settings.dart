import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/controllers/app_controller.dart';
import 'package:rss_feed/controllers/color_controller.dart';

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
                            const Text(
                              'Bạn chưa đăng nhập',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Vui lòng đăng nhập để đồng bộ dữ liệu',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Phần hiển thị
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

              // Cá nhân hoá
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'CÁ NHÂN HOÁ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.topic),
                title: const Text('Chọn chủ đề đọc'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => appController.goToChooseTopic(),
              ),
              ListTile(
                leading: const Icon(Icons.data_saver_off),
                title: const Text('Dữ liệu cá nhân hoá từ bạn'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => appController.goToChooseTopic(),
              ),

              const SizedBox(height: 16),

              // Cá nhân hoá
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'HÀNH ĐỘNG ĐỐI VỚI TÀI KHOẢN',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.backup_outlined),
                title: const Text('Sao lưu và khôi phục'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => appController.goToBackupAndRestore(),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Thông tin cá nhân'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => appController.goToAccountInfo(),
              ),
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
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
