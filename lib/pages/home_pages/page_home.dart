import 'package:flutter/material.dart';
import 'package:rss_feed/controllers/feed_controller.dart';
import '../../components/category_selection_bar.dart';
import '../../components/feed_list.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  final FeedController _feedController = FeedController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    await _feedController.loadData();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trang chủ", style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: search action
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          CategorySelectionBar(
            categories: _feedController.categories,
            selectedCategory: _feedController.selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _feedController.selectCategory(category);
              });
            },
          ),
          Expanded(
            child: FeedList(
              items: _feedController.filteredFeedItems,
              emptyCategory: _feedController.selectedCategory,
              onItemTap: (item) {
                debugPrint('Tapped on: ${item.title}');
              },
            ),
          ),
        ],
      ),
    );
  }
}
