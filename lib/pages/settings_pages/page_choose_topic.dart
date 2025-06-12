import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/controllers/color_controller.dart';
import 'package:rss_feed/controllers/choose_keyword_controller.dart';
import 'package:rss_feed/types/recommend_keyword.dart';
import 'package:rss_feed/controllers/home_controller.dart';

class PageChooseTopic extends StatelessWidget {
  PageChooseTopic({super.key});

  final ColorController colorController = Get.find<ColorController>();
  final ChooseKeywordController controller = Get.put(ChooseKeywordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chủ đề đọc",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Obx(() => TextButton(
            onPressed: controller.isLoading.value ? null : _handleSave,
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    "Lưu",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
          )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Chọn chủ đề yêu thích",
              style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Chọn ít nhất 5 chủ đề để cá nhân hóa nội dung",
              style: Theme.of(Get.context!).textTheme.bodyLarge?.copyWith(
                color: Theme.of(Get.context!).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            
            Obx(() => _buildKeywordSection()),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildKeywordSection() {
    if (controller.displayKeywords.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: controller.displayKeywords
          .map(_buildKeywordChip)
          .toList(),
    );
  }

  Widget _buildKeywordChip(RecommendKeyword keyword) {
    return Obx(() {
      final isSelected = controller.selectedKeywords.contains(keyword);
      final hasRelated = controller.loadedRelatedKeywords.contains(keyword.keywordId);
      
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          color: isSelected 
              ? Theme.of(Get.context!).colorScheme.primaryContainer
              : Theme.of(Get.context!).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: () => _handleKeywordTap(keyword),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    keyword.keywordName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: isSelected 
                          ? Theme.of(Get.context!).colorScheme.onPrimaryContainer
                          : Theme.of(Get.context!).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (hasRelated) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: isSelected 
                          ? Theme.of(Get.context!).colorScheme.onPrimaryContainer
                          : Theme.of(Get.context!).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void _handleKeywordTap(RecommendKeyword keyword) {
    controller.toggleKeyword(keyword);
    
    // Load related keywords nếu chưa load
    if (!controller.loadedRelatedKeywords.contains(keyword.keywordId)) {
      controller.loadRelatedKeywords(keyword.keywordName, keyword.keywordId);
    }
  }

  Future<void> _handleSave() async {
    if (!controller.canProceed) {
      Get.snackbar(
        "Chưa đủ chủ đề",
        "Vui lòng chọn ít nhất 5 chủ đề",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await controller.saveKeywords();
      Get.delete<HomeController>();
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar(
        "Lỗi",
        "Không thể lưu chủ đề, vui lòng thử lại",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}