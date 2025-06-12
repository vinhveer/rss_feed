import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/controllers/page_read_controller.dart';
import 'package:rss_feed/components/reading_button/reading_button.dart';
import '../controllers/browser_controller.dart';
import '../controllers/share_controller.dart';
import '../controllers/reading_controller.dart';
import 'package:rss_feed/components/markdown/article_markdown_component.dart';
import 'package:rss_feed/components/card_list/feed_item_card.dart';

class PageRead extends StatefulWidget {
  final String url;
  final bool isVn;
  final int articleId;

  const PageRead({
    super.key,
    required this.url,
    required this.isVn,
    required this.articleId,
  });

  @override
  State<PageRead> createState() => _PageReadState();
}

class _PageReadState extends State<PageRead> {
  late final PageReadController _controller;
  late final ReadingController _readingController;
  late final ShareController _shareController;
  late final BrowserController _browserController;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      PageReadController(
        url: widget.url,
        isVn: widget.isVn,
        articleId: widget.articleId,
      ),
      tag: widget.url,
    );
    _shareController = Get.put(ShareController());
    _browserController = Get.put(BrowserController());

    if (Get.isRegistered<ReadingController>(tag: widget.url)) {
      _readingController = Get.find<ReadingController>(tag: widget.url);
    } else {
      _readingController = Get.put(
        ReadingController(isVn: widget.isVn),
        tag: widget.url,
      );
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<ReadingController>(tag: widget.url)) {
      _readingController.stop();
      Get.delete<ReadingController>(tag: widget.url);
    }
    Get.delete<PageReadController>(tag: widget.url);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body: Obx(() => _buildBody(theme)),
    );
  }

  AppBar _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
      foregroundColor: theme.appBarTheme.foregroundColor,
      actions: [
        Obx(() => _controller.isTranslating
            ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
        )
            : IconButton(
          icon: Icon(
            Icons.translate,
            color: _controller.isTranslated
                ? theme.colorScheme.primary
                : theme.iconTheme.color,
          ),
          tooltip: _controller.isTranslated ? 'Xem bản gốc' : 'Dịch bài viết',
          onPressed: _controller.toggleTranslation,
        )),
        IconButton(
          icon: Icon(
            Icons.text_fields,
            color: theme.iconTheme.color,
          ),
          tooltip: 'Điều chỉnh cỡ chữ',
          onPressed: () => _showFontSizeDialog(theme),
        ),
        IconButton(
          icon: Icon(Icons.public, color: theme.iconTheme.color),
          tooltip: 'Mở trong trình duyệt',
          onPressed: () => _browserController.openInBrowser(context, widget.url),
        ),
        Obx(() => IconButton(
          icon: Icon(Icons.share, color: theme.iconTheme.color),
          tooltip: 'Chia sẻ',
          onPressed: _controller.article == null
              ? null
              : () => _shareController.shareItem(_controller.article!.title),
        )),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showFontSizeDialog(ThemeData theme) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.text_fields,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Cỡ chữ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Preview text
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Obx(() => Text(
                      'Đây là văn bản mẫu với cỡ chữ ${_controller.fontSize.round()}px',
                      style: TextStyle(
                        fontSize: _controller.fontSize,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    )),
                  ),
                  const SizedBox(height: 24),

                  // Font size value display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cỡ chữ hiện tại',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurface.withAlpha(179),
                        ),
                      ),
                      Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_controller.fontSize.round()}px',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Slider
                  Obx(() => SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 20,
                      ),
                      activeTrackColor: theme.colorScheme.primary,
                      inactiveTrackColor: theme.colorScheme.primary,
                      thumbColor: theme.colorScheme.primary,
                      overlayColor: theme.colorScheme.primary,
                    ),
                    child: Slider(
                      value: _controller.fontSize,
                      min: PageReadController.minFontSize,
                      max: PageReadController.maxFontSize,
                      divisions: (PageReadController.maxFontSize - PageReadController.minFontSize).round(),
                      onChanged: (value) {
                        _controller.updateFontSize(value);
                        setState(() {}); // Update dialog state
                      },
                    ),
                  )),

                  // Quick size buttons
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickSizeButton('Nhỏ', 14, theme),
                      _buildQuickSizeButton('Vừa', 16, theme),
                      _buildQuickSizeButton('Lớn', 18, theme),
                      _buildQuickSizeButton('Rất lớn', 22, theme),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _controller.updateFontSize(16); // Reset to default
                Navigator.of(context).pop();
              },
              child: Text(
                'Đặt lại',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withAlpha(179),
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Xong'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickSizeButton(String label, double size, ThemeData theme) {
    return Obx(() {
      final isSelected = (_controller.fontSize - size).abs() < 1;
      return InkWell(
        onTap: () => _controller.updateFontSize(size),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withAlpha(25)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withAlpha(76),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBody(ThemeData theme) {
    if (_controller.loading) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      );
    }

    if (_controller.article == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Không thể tải bài viết.",
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _controller.retryLoadArticle,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text("Thử lại"),
            )
          ],
        ),
      );
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildArticleHeader(theme),
              _buildMainImage(theme),
              const SizedBox(height: 20),
              _buildArticleContent(theme),
              const SizedBox(height: 40),
              // Bài viết liên quan
              Obx(() {
                if (_controller.isLoadingRelated.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_controller.relatedArticles.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Bài viết liên quan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._controller.relatedArticles.map((item) => FeedItemCard(
                      item: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PageRead(
                              url: item.link,
                              isVn: widget.isVn,
                              articleId: item.articleId,
                            ),
                          ),
                        );
                      },
                    )).toList(),
                  ],
                );
              }),
              const SizedBox(height: 120),
            ],
          ),
        ),
        _buildReadingButton(),
      ],
    );
  }

  Widget _buildArticleHeader(ThemeData theme) {
    final article = _controller.article!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          article.title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.pubDate,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMainImage(ThemeData theme) {
    final article = _controller.article!;
    final mainImage = article.images.isNotEmpty &&
        Uri.tryParse(article.images.first.toString())?.hasAbsolutePath ==
            true &&
        article.images.first.toString().startsWith('http')
        ? article.images.first.toString()
        : null;

    if (mainImage == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        mainImage,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 220,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          height: 220,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.broken_image,
            size: 60,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildArticleContent(ThemeData theme) {
    return Obx(() => ArticleMarkdownComponent(
      text: _controller.article!.text,
      fontSize: _controller.fontSize,
      theme: theme,
    ));
  }

  Widget _buildReadingButton() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ReadingButton(
          controller: _readingController,
          url: widget.url,
          isVn: widget.isVn,
          articleId: widget.articleId,
        ),
      ),
    );
  }
}