import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/article_favourite_controller.dart';
import '../models/feed_item_local.dart';
import 'feed_item_card.dart';

class FeedList extends GetView<ArticleFavouriteController> {
  final List<FeedItem> items;
  final String emptyCategory;
  final Function(FeedItem)? onItemTap;

  const FeedList({
    super.key,
    required this.items,
    required this.emptyCategory,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Lọc bài bị ignore
      final filteredItems = items
          .where((item) => !controller.isIgnored(item.articleId))
          .toList();

      if (filteredItems.isEmpty) {
        return Center(
          child: Text(
            'Không có nội dung cho chủ đề $emptyCategory',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
              fontSize: 16,
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          return FeedItemCard(
            item: item,
            onTap: onItemTap != null ? () => onItemTap!(item) : null,
          );
        },
      );
    });
  }
}
