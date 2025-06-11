import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/controllers/app_controller.dart';
import 'package:rss_feed/controllers/color_controller.dart';

class PageBackupRestore extends StatelessWidget {
  const PageBackupRestore({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final colorController = Get.find<ColorController>();
    final primary = colorController.currentSwatch;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sao lưu và phục hồi",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bản sao lưu gần nhất
                    const Text(
                      "Bản sao lưu gần nhất",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Thời gian: 19/04/2025 - 16:32"),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đang thực hiện sao lưu...')),
                        );
                      },
                      child: const Text('Sao lưu ngay'),
                    ),
                  ],
                ),
            ),

            const SizedBox(height: 20),

            // Danh sách các tùy chọn
            ListTile(
              leading: const Icon(Icons.topic),
              title: const Text('Đặt giờ sao lưu và khôi phục'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => appController.goToChooseTopic(),
            ),

            ListTile(
              leading: const Icon(Icons.data_saver_off),
              title: const Text('Danh sách các bản sao lưu'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => appController.goToChooseTopic(),
            ),

            ListTile(
              leading: const Icon(Icons.data_saver_off),
              title: const Text('Đồng bộ dữ liệu'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => appController.goToChooseTopic(),
            ),

            const SizedBox(height: 20),

            Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thông tin sao lưu
                    const Text(
                      "Thông tin sao lưu",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Sao lưu sẽ lưu trữ dữ liệu của bạn vào bộ nhớ thiết bị."),
                    const SizedBox(height: 5),
                    const Text("Đồng bộ dữ liệu cho phép bạn sao lưu dữ liệu lên đám mây."),
                    const SizedBox(height: 5),
                    const Text("Bạn có thể đặt lịch tự động sao lưu theo thời gian đã cài đặt."),
                  ],
                ),
            )
          ]
        ),
      ),
    );
  }
}