import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/controllers/article_controller.dart';
import 'package:rss_feed/components/card_list/feed_item_card.dart';
import 'package:rss_feed/components/filter_bar/category_selection_bar.dart';

class PageArticle extends StatefulWidget {
  final int id; // newspaper_id hoặc topic_id
  final bool isTopic;
  final String title;

  const PageArticle({super.key, required this.id, required this.isTopic, required this.title});

  @override
  State<PageArticle> createState() => _PageArticleState();
}

class _PageArticleState extends State<PageArticle> {
  late final ArticleController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = Get.put(ArticleController(id: widget.id, isTopic: widget.isTopic));

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _controller.loadArticles(); // load more
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Xóa controller khi rời trang để tránh leak
    Get.delete<ArticleController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          Obx(() => (_controller.isLoading.value || _controller.isLoadingMore.value)
              ? Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
        bottom: widget.isTopic
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: _buildTopicChips(),
              ),
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.articles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => _controller.loadArticles(refresh: true),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            itemCount: _controller.articles.length + (_controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < _controller.articles.length) {
                final item = _controller.articles[index];
                return FeedItemCard(item: item);
              }

              // Indicator khi load thêm cuối list
              if (_controller.isLoadingMore.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // Không còn dữ liệu
              return const SizedBox.shrink();
            },
          ),
        );
      }),
    );
  }

  Widget _buildTopicChips() {
    return Obx(() {
      if (widget.isTopic) return const SizedBox.shrink();

      // Danh sách tên category: "Mới nhất" + các topic
      final List<String> categories = [
        'Mới nhất',
        ..._controller.topics.map((t) => t.topicName)
      ];

      // Xác định category đang chọn
      String selectedCategory = 'Mới nhất';
      if (_controller.selectedTopicId.value != null) {
        final int idx = _controller.topics.indexWhere(
            (t) => t.topicId == _controller.selectedTopicId.value);
        if (idx >= 0) {
          selectedCategory = _controller.topics[idx].topicName;
        }
      }

      return CategorySelectionBar(
        categories: categories,
        selectedCategory: selectedCategory,
        onCategorySelected: (name) {
          if (name == 'Mới nhất') {
            _controller.selectTopic(null);
          } else {
            // Lấy index trong categories (bắt đầu từ 1 cho topics)
            final int idx = categories.indexOf(name);
            if (idx >= 1 && idx - 1 < _controller.topics.length) {
              _controller.selectTopic(_controller.topics[idx - 1].topicId);
            }
          }
        },
      );
    });
  }
} 