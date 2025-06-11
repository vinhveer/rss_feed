import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/controllers/color_controller.dart';

class PageAccountInfo extends StatelessWidget {
  const PageAccountInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final colorController = Get.find<ColorController>();
    final primary = colorController.currentSwatch;
    
    // Dữ liệu mẫu của người dùng
    final userData = {
      'username': 'trittntu',
      'name': 'Nguyễn Văn A',
      'email': 'trittntu@example.com',
      'phone': '0912345678',
      'joinDate': '10/01/2024',
      'lastLogin': '19/04/2025',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thông tin tài khoản',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              // Điều hướng đến trang chỉnh sửa thông tin
              Get.toNamed('/edit-account');
              // Hoặc hiển thị dialog chỉnh sửa
              // _showEditDialog(context, userData);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Chỉnh sửa'),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ảnh đại diện
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Tên người dùng
            Text(
              userData['name']!,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '@${userData['username']!}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),

            // Thông tin chi tiết
            _buildInfoItem(Icons.email, 'Email', userData['email']!),
            _buildInfoItem(Icons.phone, 'Số điện thoại', userData['phone']!),
            _buildInfoItem(Icons.calendar_today, 'Ngày tham gia', userData['joinDate']!),
            _buildInfoItem(Icons.login, 'Đăng nhập gần đây', userData['lastLogin']!),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}