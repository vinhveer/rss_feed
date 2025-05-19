import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:rss_feed/pages/reading_button_pages/reading_button.dart';
import '../repository/article_content_repository.dart';
import '../controllers/reading_controller.dart'; // Đặt file controller ở đây

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

  const PageRead({super.key, required this.url});

  @override
  State<PageRead> createState() => _PageReadState();
}

class _PageReadState extends State<PageRead> {
  ArticleData? _article;
  bool _loading = true;
  late final ReadingController _readingController;

  @override
  void initState() {
    super.initState();
    _readingController = Get.put(ReadingController(), tag: widget.url);

    _loadArticle();
  }

  Future<void> _loadArticle() async {
    final repo = ArticleContentRepository();
    final result = await repo.fetchArticleContent(widget.url);
    setState(() {
      _article = result != null ? ArticleData.fromJson(result) : null;
      _loading = false;
    });
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
        actions: const [
          IconButton(icon: Icon(Icons.translate), tooltip: 'Dịch', onPressed: null),
          IconButton(icon: Icon(Icons.text_fields), tooltip: 'Cỡ chữ', onPressed: null),
          IconButton(icon: Icon(Icons.public), tooltip: 'Chế độ đọc', onPressed: null),
          IconButton(icon: Icon(Icons.share), tooltip: 'Chia sẻ', onPressed: null),
          SizedBox(width: 8),
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
                          Text(article.author,
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1),
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
                MarkdownBody(
                  data: article.text,
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
                ),
                const SizedBox(height: 150),
              ],
            ),
          ),
          // Sử dụng ReadingButton với controller GetX
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ReadingButton(controller: _readingController, url: widget.url),
            ),
          ),
        ],
      ),
    );
  }
}