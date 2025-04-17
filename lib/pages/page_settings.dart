import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/controllers/app_controller.dart';

class PageSettings extends StatelessWidget {
  const PageSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card đăng nhập
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Avatar bên trái
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Text bên phải
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bạn chưa đăng nhập',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Vui lòng đăng nhập để đồng bộ dữ liệu',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Icon mũi tên
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Phần Hiển thị
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
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Chế độ hiển thị'),
              subtitle: const Text('Sáng / tối / mặc định'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                appController.goToThemeModeSettingPage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Chọn màu'),
              subtitle: const Text('Các màu trong material cho giao diện'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                appController.goToColorSchemeSettingsPage();
              },
            ),

            const SizedBox(height: 16),

            // Phần Cá nhân hoá
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
              onTap: () {
                // Sử dụng GetX để chuyển trang
                appController.goToChooseTopic();
              },
            ),

            // Có thể thêm các mục cài đặt khác ở đây
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Thông tin ứng dụng'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Xử lý khi nhấn vào thông tin ứng dụng
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: const Text('Gửi phản hồi'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Xử lý khi nhấn vào gửi phản hồi
              },
            ),
          ],
        ),
      ),
    );
  }
}