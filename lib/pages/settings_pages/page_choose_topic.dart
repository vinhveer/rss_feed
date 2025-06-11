import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/controllers/color_controller.dart';
import 'package:rss_feed/controllers/choose_keyword_controller.dart';
import 'package:rss_feed/types/recommend_keyword.dart';

class PageChooseTopic extends StatelessWidget {
  PageChooseTopic({super.key});

  final ColorController colorController = Get.find<ColorController>();
  final ChooseKeywordController controller = Get.put(ChooseKeywordController());

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
            onPressed: () async {
              if (!controller.canProceed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.redAccent,
                    content: Text("Vui lòng chọn ít nhất 5 từ khóa"),
                  ),
                );
              } else {
                await controller.saveKeywords();
              }
            },
            child: Obx(() => controller.isLoading.value
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(primary),
                  ),
                )
              : Text(
                  "Lưu và về trang chủ",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
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
              "Chọn các từ khóa bạn thích",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Các từ khóa sẽ được dùng để cá nhân hóa nội dung cho bạn",
              style: TextStyle(fontSize: 15),
            ),
            const Text(
              "Chọn ít nhất 5 từ khóa trở lên. Click vào từ khóa để khám phá thêm từ khóa liên quan!",
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 10),

            // Hiển thị tất cả từ khóa theo thứ tự tuyến tính
            Obx(() => _buildLinearKeywordList(primary)),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildLinearKeywordList(MaterialColor primary) {
    if (controller.displayKeywords.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Từ khóa",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        
        // Hiển thị tất cả keywords trong một Wrap duy nhất
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: controller.displayKeywords.map((keyword) {
            return _buildKeywordChip(keyword, primary);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildKeywordChip(RecommendKeyword keyword, MaterialColor primary) {
    return Obx(() {
      final isSelected = controller.selectedKeywords.contains(keyword);
      final hasLoadedRelated = controller.loadedRelatedKeywords.contains(keyword.keywordId);
      
      return GestureDetector(
        onTap: () {
          // Toggle chọn keyword
          controller.toggleKeyword(keyword);
          
          // Load related keywords nếu chưa load
          if (!hasLoadedRelated) {
            controller.loadRelatedKeywords(keyword.keywordName, keyword.keywordId);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: isSelected ? primary : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primary : Colors.grey[300] ?? Colors.grey,
              width: isSelected ? 2 : 1,
            ),
            // Thêm shadow nhẹ cho keyword đã được mở rộng
            boxShadow: hasLoadedRelated ? [
              BoxShadow(
                color: primary.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                keyword.keywordName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
              
              // Hiển thị indicator dựa trên trạng thái
              if (!hasLoadedRelated && !controller.isLoading.value) ...[
                // Chưa load và không đang loading - hiển thị icon add
                const SizedBox(width: 5),
                Icon(
                  Icons.add_circle_outline,
                  size: 16,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ] else if (!hasLoadedRelated && controller.isLoading.value) ...[
                // Đang loading - hiển thị loading indicator
                const SizedBox(width: 8),
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isSelected ? Colors.white : primary,
                    ),
                  ),
                ),
              ] else ...[
                // Đã load xong - hiển thị icon check
                const SizedBox(width: 5),
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: isSelected ? Colors.white : Colors.green,
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}