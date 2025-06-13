import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/card_list/feed_item_card.dart';
import '../../controllers/search_controller.dart' as search;
import '../page_read.dart';

class PageSearchArticle extends StatelessWidget {
  final search.SearchController _controller = Get.put(search.SearchController());
  final TextEditingController _textController = TextEditingController();

  PageSearchArticle({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm bài viết...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
          onSubmitted: (query) => _controller.searchArticles(query),
          textInputAction: TextInputAction.search,
        ),
        actions: [
          Obx(() => _controller.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _textController.clear();
                    _controller.clearSearch();
                  },
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (_controller.searchQuery.isEmpty) {
          return const Center(
            child: Text('Nhập từ khóa để tìm kiếm bài viết'),
          );
        }

        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _controller.searchArticles(_controller.searchQuery.value),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (_controller.searchResults.isEmpty) {
          return const Center(
            child: Text('Không tìm thấy kết quả nào'),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
              _controller.loadMoreResults();
            }
            return true;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.searchResults.length + (_controller.hasMoreResults.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _controller.searchResults.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final item = _controller.searchResults[index];
              return FeedItemCard(
                item: item,
                onTap: () {
                  Get.to(() => PageRead(
                    url: item.link,
                    isVn: item.isVn,
                    articleId: item.articleId,
                  ));
                },
              );
            },
          ),
        );
      }),
    );
  }
}
