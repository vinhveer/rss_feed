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
  // Create a controller instance
  final FeedController _feedController = FeedController();

  @override
  void initState() {
    super.initState();

    _feedController.loadData().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trang chủ", style: TextStyle(fontWeight: FontWeight.w600),),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Handle search action
            }
          )
        ],
      ),
      body: Column(
        children: [
          // Replace custom implementation with CategorySelectionBar
          CategorySelectionBar(
            categories: _feedController.categories,
            selectedIndex: _feedController.selectedCategoryIndex,
            onCategorySelected: (index) {
              setState(() {
                _feedController.selectCategory(index);
              });
            },
          ),

          // Replace custom implementation with FeedList
          Expanded(
            child: FeedList(
              items: _feedController.filteredFeedItems,
              emptyCategory: _feedController.selectedCategory,
              onItemTap: (item) {
                // Handle item tap - you can add navigation logic here
                debugPrint('Tapped on: ${item.title}');
              },
            ),
          ),
        ],
      ),
    );
  }
}