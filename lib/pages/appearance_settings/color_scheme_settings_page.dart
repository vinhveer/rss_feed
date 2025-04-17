import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/controllers/color_controller.dart';

class ColorSchemeSettingsPage extends StatelessWidget {
  const ColorSchemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorController controller = Get.find<ColorController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chọn màu chủ đạo',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: ColorController.availableColors.length,
        itemBuilder: (context, index) {
          final item = ColorController.availableColors[index];

          return Obx(() {
            final isSelected = item.color == controller.primarySwatch.value;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: item.color,
              ),
              title: Text(item.name),
              trailing: isSelected ? Icon(Icons.check, color: colorScheme.primary) : null,
              onTap: () => controller.changePrimaryColor(item.color),
              selected: isSelected,
            );
          });
        },
      ),
    );
  }
}