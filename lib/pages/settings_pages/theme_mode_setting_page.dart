import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/controllers/color_controller.dart';

class ThemeModeSettingPage extends StatelessWidget {
  const ThemeModeSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorController controller = Get.find<ColorController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chế độ hiển thị',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: Obx(() {
        final currentMode = controller.themeMode.value;

        return ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Sáng'),
              trailing: currentMode == ThemeMode.light
                  ? Icon(Icons.check, color: colorScheme.primary)
                  : null,
              onTap: () => controller.changeThemeMode(ThemeMode.light),
              selected: currentMode == ThemeMode.light,
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Tối'),
              trailing: currentMode == ThemeMode.dark
                  ? Icon(Icons.check, color: colorScheme.primary)
                  : null,
              onTap: () => controller.changeThemeMode(ThemeMode.dark),
              selected: currentMode == ThemeMode.dark,
            ),
            ListTile(
              leading: const Icon(Icons.settings_suggest),
              title: const Text('Theo hệ thống'),
              trailing: currentMode == ThemeMode.system
                  ? Icon(Icons.check, color: colorScheme.primary)
                  : null,
              onTap: () => controller.changeThemeMode(ThemeMode.system),
              selected: currentMode == ThemeMode.system,
            ),
          ],
        );
      }),
    );
  }
}
