import 'package:flutter/material.dart';
import '../models/feed_item.dart';
import 'feed_item_card.dart';

class FeedList extends StatelessWidget {
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
    if (items.isEmpty) {
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
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return FeedItemCard(
          item: item,
          onTap: onItemTap != null ? () => onItemTap!(item) : null,
        );
      },
    );
  }
}