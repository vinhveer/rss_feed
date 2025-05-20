import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/components/item_action_bar.dart';
import 'package:rss_feed/pages/page_read.dart';
import '../models/feed_item_local.dart';
import 'package:share_plus/share_plus.dart';

class FeedItemCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback? onTap;

  const FeedItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  void _shareItem(String title) {
    SharePlus.instance.share(
      ShareParams(
        text: 'Tin tức thú vị hôm nay! $title',
      ),
    );
  }

  Future<void> _showUninterestedDialog(BuildContext context, String title) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Bạn có chắc chắn không quan tâm?"),
          content: const Text("Chúng tôi sẽ hạn chế hiển thị nội dung này."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Có"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Không"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Get.to(() => PageRead(url: item.link ,isVn: item.isVn));
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/defaultimage.jpg',
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        item.source,
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        item.timeAgo,
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Hiển thị danh sách keywords
                  if (item.keywords.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: item.keywords.map((kw) {
                        return Chip(
                          label: Text(
                            kw,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 8),

                  ItemActionBar(
                    onLeftAction: () => _shareItem(item.title),
                    onRightAction: () => _showUninterestedDialog(context, item.title),
                    leftIcon: Icons.share,
                    rightIcon: Icons.block,
                    leftTooltip: 'Chia sẻ',
                    rightTooltip: 'Không quan tâm',
                    isVisible: true,
                    compact: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
