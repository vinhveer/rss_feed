import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../components/card_list/feed_item_card.dart';
import '../../components/filter_bar/category_selection_bar.dart';
import '../../types/feed_item_local.dart';
import 'page_search_article.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  late final HomeController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = Get.put(HomeController());

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _controller.loadArticles(); // load more
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    Get.delete<HomeController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trang chủ", style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Get.to(() => PageSearchArticle()),
          ),
          Obx(() => (_controller.isLoadingArticles.value || _controller.isLoadingMore.value)
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildTopicChips(),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoadingArticles.value && _controller.articles.isEmpty) {
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
                final article = _controller.articles[index];
                final feedItem = FeedItem(
                  articleId: article.articleId,
                  title: article.title,
                  source: article.description,
                  timeAgo: article.pubDate.toString(),
                  imageUrl: article.imageUrl,
                  category: '',
                  link: article.link,
                  isVn: true,
                  keywords: const [],
                );
                return FeedItemCard(item: feedItem);
              }

              // Loading indicator at the end of list
              if (_controller.isLoadingMore.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        );
      }),
    );
  }

  Widget _buildTopicChips() {
    return Obx(() {
      if (_controller.isLoadingKeywords.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Danh sách tên category: "Đề xuất cho bạn", "Nổi bật" + các keyword
      final List<String> categories = [
        'Đề xuất cho bạn',
        'Nổi bật',
        ..._controller.keywords.map((k) => k.keywordName)
      ];

      return CategorySelectionBar(
        categories: categories,
        selectedCategory: _controller.selectedCategory.value,
        onCategorySelected: (name) {
          _controller.selectCategory(name);
        },
      );
    });
  }
}
