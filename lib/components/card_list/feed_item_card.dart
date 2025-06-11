import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/components/card_list/item_action_bar.dart';
import 'package:rss_feed/pages/page_read.dart';
import '../../controllers/article_favourite_controller.dart';
import '../../types/feed_item_local.dart';
import '../../repositories/keyword_repository.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class FeedItemCard extends StatefulWidget {
  final FeedItem item;
  final VoidCallback? onTap;
  final bool isSelectMode;
  final bool isSelected;
  final VoidCallback? onSelect;

  const FeedItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.isSelectMode = false,
    this.isSelected = false,
    this.onSelect,
  });

  @override
  State<FeedItemCard> createState() => _FeedItemCardState();
}

class _FeedItemCardState extends State<FeedItemCard> {
  bool isFavourited = false;
  final ArticleFavouriteController _favouriteController = Get.find<ArticleFavouriteController>();
  final KeywordRepository _keywordRepository = KeywordRepository();
  bool _isImageLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavouriteStatus();
  }

  Future<void> _loadFavouriteStatus() async {
    final status = await _favouriteController.isFavourited(widget.item.articleId);
    if (mounted) {
      setState(() {
        isFavourited = status;
      });
    }
  }

  void _shareItem(String title) {
    SharePlus.instance.share(
      ShareParams(
        text: 'Tin tức thú vị hôm nay! $title',
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes} phút trước';
        }
        return '${difference.inHours} giờ trước';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ngày trước';
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _toggleFavourite() async {
    try {
      if (isFavourited) {
        await _favouriteController.removeFromFavourite(widget.item.articleId);
        if (mounted) {
          setState(() => isFavourited = false);
          Get.snackbar(
            'Đã xóa',
            'Đã xóa khỏi mục yêu thích',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.primary,
            colorText: Get.theme.colorScheme.onPrimary,
          );
        }
      } else {
        await _favouriteController.addToFavourite(widget.item.articleId);
        if (mounted) {
          setState(() => isFavourited = true);
          Get.snackbar(
            'Đã thêm',
            'Đã thêm vào mục yêu thích',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.primary,
            colorText: Get.theme.colorScheme.onPrimary,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Lỗi',
          'Có lỗi xảy ra, vui lòng thử lại',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    }
  }

  Future<void> _handleArticleTap() async {
    // Lưu keywords vào local storage
    await _keywordRepository.addKeywordsToStorage(widget.item.articleId);
    
    // Chuyển đến trang đọc bài viết
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      Get.to(() => PageRead(
            url: widget.item.link,
            isVn: widget.item.isVn,
            articleId: widget.item.articleId,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: widget.isSelected 
            ? const BorderSide(color: Colors.blue, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: widget.isSelectMode
            ? widget.onSelect
            : _handleArticleTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.item.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              _isImageLoading = false;
                              return child;
                            }
                            return Container(
                              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDarkMode ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/defaultimage.jpg',
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                        if (_isImageLoading)
                          Container(
                            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (widget.isSelectMode)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.isSelected ? Colors.blue : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.isSelected ? Colors.blue : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.check,
                          size: 20,
                          color: widget.isSelected ? Colors.white : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.title,
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
                        widget.item.source,
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
                        _formatDate(widget.item.timeAgo),
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Hiển thị danh sách keywords
                  if (widget.item.keywords.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.item.keywords.map((kw) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            kw.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode 
                                  ? Colors.blue[200]
                                  : Colors.blue[700],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 8),

                  ItemActionBar(
                    onLeftAction: () => _shareItem(widget.item.title),
                    onRightAction: _toggleFavourite,
                    leftIcon: Icons.share,
                    rightIcon: isFavourited ? Icons.favorite : Icons.favorite_border,
                    leftTooltip: 'Chia sẻ',
                    rightTooltip: isFavourited ? 'Bỏ yêu thích' : 'Yêu thích',
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
