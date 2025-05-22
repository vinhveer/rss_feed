import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/controllers/reading_controller.dart';
import '../controllers/article_favourite_controller.dart';

class ReadingButton extends StatefulWidget {
  final ReadingController controller;
  final String url;
  final bool isVn;
  final int articleId;

  const ReadingButton({
    super.key,
    required this.controller,
    required this.url,
    required this.isVn,
    required this.articleId,
  });

  @override
  State<ReadingButton> createState() => _ReadingButtonState();
}

class _ReadingButtonState extends State<ReadingButton> with TickerProviderStateMixin {
  bool isFavourited = false;
  final ArticleFavouriteController _favouriteController = ArticleFavouriteController();
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadFavouriteStatus();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadFavouriteStatus() async {
    final status = await _favouriteController.isFavourited(widget.articleId);
    if (mounted) {
      setState(() {
        isFavourited = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      // Trigger animation based on reading state
      if (widget.controller.isReading.value) {
        _slideController.forward();
      } else {
        _slideController.reverse();
      }

      if (widget.controller.isReading.value) {
        return SlideTransition(
          position: _slideAnimation,
          child: Container(
            height: 90,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(isDark ? 0.3 : 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Speed Control
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<double>(
                    value: widget.controller.speechRate.value,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      fontSize: 14,
                    ),
                    underline: const SizedBox(),
                    isDense: true,
                    onChanged: (value) {
                      if (value != null) {
                        widget.controller.setSpeechRate(value);
                      }
                    },
                    dropdownColor: theme.colorScheme.surface,
                    items: const [
                      DropdownMenuItem(value: 0.5, child: Text("0.5×")),
                      DropdownMenuItem(value: 0.75, child: Text("0.75×")),
                      DropdownMenuItem(value: 1.0, child: Text("1×")),
                      DropdownMenuItem(value: 1.25, child: Text("1.25×")),
                      DropdownMenuItem(value: 1.5, child: Text("1.5×")),
                      DropdownMenuItem(value: 2.0, child: Text("2×")),
                    ],
                  ),
                ),

                // Media Controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildControlButton(
                      icon: Icons.replay_10_rounded,
                      tooltip: "Lùi lại 10 giây",
                      onPressed: widget.controller.skipBackward,
                      theme: theme,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.8),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: widget.controller.toggleReading,
                          child: Container(
                            width: 48,
                            height: 48,
                            child: Icon(
                              widget.controller.isPlaying.value
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: theme.colorScheme.onPrimary,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildControlButton(
                      icon: Icons.forward_10_rounded,
                      tooltip: "Tiến 10 giây",
                      onPressed: widget.controller.skipForward,
                      theme: theme,
                    ),
                  ],
                ),

                // Close Button
                _buildControlButton(
                  icon: Icons.close_rounded,
                  tooltip: "Dừng đọc",
                  onPressed: widget.controller.stop,
                  theme: theme,
                  isDestructive: true,
                ),
              ],
            ),
          ),
        );
      } else {
        return Container(
          margin: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Action Buttons
              Row(
                children: [
                  _buildFloatingButton(
                    heroTag: 'favorite',
                    icon: isFavourited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFavourited ? Colors.pink : theme.colorScheme.onSurface,
                    backgroundColor: theme.colorScheme.surface,
                    tooltip: isFavourited ? "Bỏ yêu thích" : "Yêu thích",
                    onPressed: _toggleFavourite,
                    theme: theme,
                  ),
                  const SizedBox(width: 12),
                  _buildFloatingButton(
                    heroTag: 'not_interested',
                    icon: Icons.visibility_off_rounded,
                    color: theme.colorScheme.onSurface,
                    backgroundColor: theme.colorScheme.surface,
                    tooltip: "Ẩn bài viết",
                    onPressed: _ignoreArticle,
                    theme: theme,
                  ),
                ],
              ),

              // Play Button
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () async {
                      await widget.controller.readArticle(widget.url, isVn: widget.isVn);
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: theme.colorScheme.onPrimary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  Widget _buildControlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    required ThemeData theme,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDestructive
            ? theme.colorScheme.errorContainer.withOpacity(0.1)
            : theme.colorScheme.surfaceVariant,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Container(
            width: 40,
            height: 40,
            child: Icon(
              icon,
              size: 20,
              color: isDestructive
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButton({
    required String heroTag,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required String tooltip,
    required VoidCallback onPressed,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onPressed,
          child: Container(
            width: 48,
            height: 48,
            child: Icon(icon, color: color, size: 22),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleFavourite() async {
    try {
      if (isFavourited) {
        await _favouriteController.removeFromFavourite(widget.articleId);
        if (mounted) {
          setState(() => isFavourited = false);
          _showSnackbar('Đã xóa khỏi mục yêu thích', Icons.favorite_border_rounded);
        }
      } else {
        await _favouriteController.addToFavourite(widget.articleId);
        if (mounted) {
          setState(() => isFavourited = true);
          _showSnackbar('Đã thêm vào mục yêu thích', Icons.favorite_rounded);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Có lỗi xảy ra, vui lòng thử lại', Icons.error_outline_rounded);
      }
    }
  }

  void _ignoreArticle() {
    _favouriteController.ignoreArticle(widget.articleId);
    _showSnackbar('Đã ẩn bài viết khỏi trang chủ', Icons.visibility_off_rounded);
  }

  void _showSnackbar(String message, IconData icon) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}