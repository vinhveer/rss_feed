import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/app.dart';
import 'package:rss_feed/controllers/setup_controller.dart';
import 'package:rss_feed/controllers/color_controller.dart';

class PageChooseTopic extends StatelessWidget {
  PageChooseTopic({super.key});

  final SetupController controller = Get.put(SetupController());
  final ColorController colorController = Get.find<ColorController>();

  @override
  Widget build(BuildContext context) {
    final primary = colorController.currentSwatch;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chủ đề đọc",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.selectedTopics.length < 5) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.redAccent,
                    content: const Text("Vui lòng chọn ít nhất 5 danh mục"),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => App()),
                );
              }
            },
            child: Text(
              "Lưu và về trang chủ",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chọn ngôn ngữ",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // New card-based language selection
            Obx(() => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: controller.languages.map((language) {
                final isSelected = controller.selectedLanguage.value == language;
                return GestureDetector(
                  onTap: () {
                    controller.selectedLanguage.value = language;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: isSelected ? primary : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? primary : Colors.grey[200] ?? Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      language,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),

            const SizedBox(height: 20),
            const Text(
              "Chọn các danh mục bạn thích",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Các danh mục sẽ được dùng để cá nhân hóa nội dung cho bạn",
              style: TextStyle(fontSize: 15),
            ),
            const Text(
              "Chọn ít nhất 5 danh mục trở lên",
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: controller.topics.map((e) {
                return Obx(() {
                  final selected = controller.selectedTopics.contains(e);
                  return GestureDetector(
                    onTap: () {
                      if (selected) {
                        controller.selectedTopics.remove(e);
                      } else {
                        controller.selectedTopics.add(e);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        color: selected ? primary : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? primary
                              : Colors.grey[200] ?? Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        e,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: selected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                });
              }).toList(),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}