import 'package:flutter/material.dart';
import 'package:rss_feed/repository/article_repository.dart';
import 'package:rss_feed/row_row_row_generated/tables/article.row.dart';

class TestPageVinh extends StatefulWidget {
  TestPageVinh({super.key});

  @override
  State<TestPageVinh> createState() => _TestPageVinhState();

  ArticleRepository articleRepository = ArticleRepository();
}

class _TestPageVinhState extends State<TestPageVinh> {
  List<ArticleRow> articles = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final fetchedArticles = await widget.articleRepository.getAllArticles();
      setState(() {
        articles = fetchedArticles;
        isLoading = false;
      });
    } on SupabaseException catch (e) {
      setState(() {
        errorMessage = 'Database error: ${e.message}';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Unexpected error: $e';
        isLoading = false;
      });
    }
  }

  Widget _buildArticleItem(BuildContext context, int index) {
    if (index >= articles.length) {
      return const Text('Invalid index');
    }

    final article = articles[index];

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article title
            Text(
              article.title?.toString() ?? 'No Title',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),

            // Article image if available
            if (article.imageUrl != null && article.imageUrl.toString().isNotEmpty)
              Container(
                height: 150,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(
                    article.imageUrl.toString(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        alignment: Alignment.center,
                        child: const Text('Image not available'),
                      );
                    },
                  ),
                ),
              ),

            // Article description
            if (article.description != null)
              Text(
                article.description.toString(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

            const SizedBox(height: 8),

            // Article publication date
            if (article.pubDate != null)
              Text(
                'Published: ${_formatDate(article.pubDate!)}',
                style: const TextStyle(color: Colors.grey),
              ),

            // Article link
            if (article.link != null)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  'Link: ${article.link.toString()}',
                  style: TextStyle(color: Colors.blue.shade700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // RSS ID
            Text(
              'RSS ID: ${article.rssId ?? 'N/A'}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeparator(BuildContext context, int index) {
    return const Divider(height: 1);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trang test của Vinh"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadArticles,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // Error message if any
            if (errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            // Loading indicator
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            // Empty state
            else if (articles.isEmpty && errorMessage.isEmpty)
              const Center(
                child: Text(
                  'No articles found',
                  style: TextStyle(fontSize: 16),
                ),
              )
            // Articles list
            else
              Expanded(
                child: ListView.separated(
                  itemBuilder: _buildArticleItem,
                  separatorBuilder: _buildSeparator,
                  itemCount: articles.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}