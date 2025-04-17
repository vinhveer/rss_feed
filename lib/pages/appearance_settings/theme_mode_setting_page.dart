// lib/pages/theme_mode_setting_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/controllers/app_controller.dart';

class ThemeModeSettingPage extends StatelessWidget {
  const ThemeModeSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chế độ hiển thị',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: Obx(() {
        final currentMode = controller.themeMode;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThemeCard(
                context: context,
                title: 'Sáng',
                icon: Icons.light_mode,
                isSelected: currentMode == ThemeMode.light,
                onTap: () => controller.changeThemeMode(ThemeMode.light),
              ),
              const SizedBox(height: 16),
              _buildThemeCard(
                context: context,
                title: 'Tối',
                icon: Icons.dark_mode,
                isSelected: currentMode == ThemeMode.dark,
                onTap: () => controller.changeThemeMode(ThemeMode.dark),
              ),
              const SizedBox(height: 16),
              _buildThemeCard(
                context: context,
                title: 'Theo hệ thống',
                icon: Icons.settings_suggest,
                isSelected: currentMode == ThemeMode.system,
                onTap: () => controller.changeThemeMode(ThemeMode.system),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildThemeCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withOpacity(0.1)
                      : colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? colorScheme.primary : null,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? colorScheme.primary : null,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}