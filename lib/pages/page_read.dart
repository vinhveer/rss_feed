import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:rss_feed/pages/reading_button_pages/reading_button.dart';
import '../controllers/translate_controller.dart';
import '../repository/article_content_repository.dart';
import '../controllers/reading_controller.dart';


class ArticleData {
  final String title;
  final String text;
  final List<dynamic> images;
  final String pubDate;
  final String author;

  ArticleData({
    required this.title,
    required this.text,
    required this.images,
    required this.pubDate,
    required this.author,
  });

  factory ArticleData.fromJson(Map<String, dynamic> json) {
    return ArticleData(
      title: json['title'] ?? '',
      text: json['text'] ?? '',
      images: (json['images'] ?? []) as List<dynamic>,
      pubDate: json['pubDate'] ?? '',
      author: json['author'] ?? '',
    );
  }
}

class PageRead extends StatefulWidget {
  final String url;
  final bool isVn;

  const PageRead({super.key, required this.url, required this.isVn});

  @override
  State<PageRead> createState() => _PageReadState();
}

class _PageReadState extends State<PageRead> {
  ArticleData? _article;
  ArticleData? _originalArticle;
  bool _loading = true;
  bool _isTranslating = false;
  bool _isTranslated = false;

  late final ReadingController _readingController;
  final TranslateService _translateService = TranslateService();

  @override
  void initState() {
    super.initState();
    _readingController = Get.put(ReadingController(isVn: widget.isVn), tag: widget.url);
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    final repo = ArticleContentRepository();
    final result = await repo.fetchArticleContent(widget.url);
    setState(() {
      _originalArticle = result != null ? ArticleData.fromJson(result) : null;
      _article = _originalArticle;
      _loading = false;
    });
  }

  Future<void> _toggleTranslation() async {
    if (_article == null || _isTranslating) return;

    if (_isTranslated) {
      setState(() {
        _article = _originalArticle;
        _isTranslated = false;
      });
      return;
    }

    setState(() {
      _isTranslating = true;
    });

    final fromLang = widget.isVn ? 'vi' : 'en';
    final toLang = widget.isVn ? 'en' : 'vi';

    try {
      final translatedTitle = await _translateService.translate(_article!.title, fromLang, toLang);
      final translatedText = await _translateService.translate(_article!.text, fromLang, toLang);

      setState(() {
        _article = ArticleData(
          title: translatedTitle,
          text: translatedText,
          images: _article!.images,
          pubDate: _article!.pubDate,
          author: _article!.author,
        );
        _isTranslated = true;
      });
    } catch (e) {
      print("Translation failed: $e");
    } finally {
      setState(() {
        _isTranslating = false;
      });
    }
  }

  @override
  void dispose() {
    _readingController.stop();
    Get.delete<ReadingController>(tag: widget.url);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_article == null) {
      return const Scaffold(body: Center(child: Text("Không thể tải bài viết.")));
    }

    final article = _article!;
    final mainImage = article.images.isNotEmpty &&
        Uri.tryParse(article.images.first.toString())?.hasAbsolutePath == true &&
        article.images.first.toString().startsWith('http')
        ? article.images.first.toString()
        : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          _isTranslating
              ? const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
              : IconButton(
            icon: const Icon(Icons.translate),
            tooltip: _isTranslated ? 'Xem bản gốc' : 'Dịch bài viết',
            onPressed: _toggleTranslation,
          ),
          IconButton(icon: const Icon(Icons.text_fields), tooltip: 'Cỡ chữ', onPressed: null),
          IconButton(icon: const Icon(Icons.public), tooltip: 'Chế độ đọc', onPressed: null),
          IconButton(icon: const Icon(Icons.share), tooltip: 'Chia sẻ', onPressed: null),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage("https://randomuser.me/api/portraits/men/32.jpg"),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.author,
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(article.pubDate, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (mainImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      mainImage,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                  ),
                const SizedBox(height: 20),
                _ArticleMarkdown(text: article.text),
                const SizedBox(height: 150),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ReadingButton(
                controller: _readingController,
                url: widget.url,
                isVn: widget.isVn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleMarkdown extends StatelessWidget {
  final String text;

  const _ArticleMarkdown({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: text,
      selectable: true,
      imageBuilder: (uri, title, alt) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Image.network(
          uri.toString(),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[300],
            height: 200,
            width: double.infinity,
            child: const Icon(Icons.broken_image, size: 60),
          ),
        ),
      ),
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: const TextStyle(fontSize: 18, height: 1.6),
      ),
    );
  }
}
