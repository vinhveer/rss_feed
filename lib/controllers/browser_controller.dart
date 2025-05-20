import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class BrowserController extends GetxController {
  Future<void> openInBrowser(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showMessage(context, 'URL không hợp lệ');
      return;
    }

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!launched && context.mounted) {
        _showMessage(context, 'Không thể mở liên kết');
      }
    } catch (e) {
      debugPrint('Lỗi khi mở link: $e');
      if (context.mounted) {
        _showMessage(context, 'Lỗi khi mở link: $e');
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
