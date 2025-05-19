import 'package:flutter/material.dart';
import 'package:rss_feed/models/feed_item_local.dart';
import '../main.dart';

class FeedController extends ChangeNotifier {
  int _selectedCategoryIndex = 0;
  List<String> categories = ['Tất cả'];
  List<FeedItem> _feedItems = [];

  // Getters
  int get selectedCategoryIndex => _selectedCategoryIndex;
  String get selectedCategory => categories[_selectedCategoryIndex];

  List<FeedItem> get filteredFeedItems {
    if (_selectedCategoryIndex == 0) {
      return _feedItems;
    } else {
      return _feedItems
          .where((item) => item.category == categories[_selectedCategoryIndex])
          .toList();
    }
  }

  void selectCategory(int index) {
    if (index != _selectedCategoryIndex &&
        index >= 0 &&
        index < categories.length) {
      _selectedCategoryIndex = index;
      notifyListeners();
    }
  }

  Future<void> loadData() async {
    try {
      // Fetch categories
      final categoryResponse = await supabase.from('topic').select('topic_name');
      final topicNames = (categoryResponse as List)
          .map((e) => e['topic_name'] as String)
          .toList();
      categories = ['Tất cả', ...topicNames];

      // Fetch articles with join to rss and topic
      final articleResponse = await supabase
          .from('article')
          .select('''
            article_id,
            title,
            link,
            image_url,
            pub_date,
            description,
            rss:rss_id (
              rss_link,
              topic:topic_id (
                topic_name
              )
            ),
            article_keyword (
              keyword:keyword_id (
                keyword_name
              )
            )
          ''')
          .order('article_id', ascending: false);

      _feedItems = (articleResponse as List).map((json) {
        final rss = json['rss'];
        final topic = rss != null ? rss['topic'] : null;

        final keywordList = (json['article_keyword'] as List?)?.map((kw) {
          return kw['keyword']?['keyword_name'] as String?;
        }).whereType<String>().toList() ?? [];

        return FeedItem(
          title: json['title'] ?? 'Không có tiêu đề',
          source: json['description'] ?? 'Mô tả',
          timeAgo: json['pub_date'] ?? 'Vừa xong',
          imageUrl: json['image_url'] ?? 'assets/images/placeholder.jpg',
          category: topic?['topic_name'] ?? 'Không rõ danh mục',
          link: json['link'] ?? '#',
          keywords: keywordList,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      return;
    }
  }

  Future<void> refreshFeed() async {
    await loadData();
  }

  void addFeedItem(FeedItem item) {
    _feedItems.add(item);
    notifyListeners();
  }
}
