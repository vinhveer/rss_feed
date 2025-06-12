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

  @override
  void initState() {
    super.initState();
    _loadFavouriteStatus();
  }

  Future<void> _loadFavouriteStatus() async {
    final status = await _favouriteController.isFavourited(widget.item.articleId);
    if (mounted) {
      setState(() => isFavourited = status);
    }
  }

  void _shareItem() {
    SharePlus.instance.share(
      ShareParams(text: 'Tin tức thú vị hôm nay! ${widget.item.title}'),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date).abs();

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes} phút trước';
        }
        return '${difference.inHours} giờ trước';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ngày trước';
      }
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _toggleFavourite() async {
    try {      
      if (isFavourited) {
        await _favouriteController.removeFromFavourite(widget.item.articleId);
      } else {
        await _favouriteController.addToFavourite(widget.item.articleId);
      }

      if (mounted) {
        setState(() => isFavourited = !isFavourited);
      }
    } catch (e) {
      Get.log(e.toString());
    }
  }

  Future<void> _handleArticleTap() async {
    await _keywordRepository.addKeywordsToStorage(widget.item.articleId);
    
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

  Widget _buildKeywordChip(String keyword) {
    return Chip(
      label: Text(
        keyword.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildSelectionOverlay() {
    if (!widget.isSelectMode) return const SizedBox.shrink();
    
    return Positioned(
      top: 12,
      right: 12,
      child: CircleAvatar(
        radius: 12,
        backgroundColor: widget.isSelected 
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
        child: Icon(
          Icons.check,
          size: 16,
          color: widget.isSelected 
              ? Theme.of(context).colorScheme.onPrimary
              : Colors.transparent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.isSelectMode ? widget.onSelect : _handleArticleTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlay
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    widget.item.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/defaultimage.jpg',
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                _buildSelectionOverlay(),
              ],
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  if (widget.item.source.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      widget.item.source,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  const SizedBox(height: 8),

                  Text(
                    _formatDate(widget.item.timeAgo),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  
                  if (widget.item.keywords.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.item.keywords
                          .map(_buildKeywordChip)
                          .toList(),
                    ),
                  ],
                  
                  const SizedBox(height: 12),
                  ItemActionBar(
                    onLeftAction: _shareItem,
                    onRightAction: _toggleFavourite,
                    leftIcon: Icons.share_outlined,
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