import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/feed_item_local.dart';


class FeedController with ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  List<FeedItem> _feedItems = [];
  List<FeedItem> get feedItems => _feedItems;

  List<String> categories = ['Tất cả'];
  String selectedCategory = 'Tất cả';

  Future<void> loadData() async {
    try {
      // Fetch topic names
      final categoryResponse =
      await supabase.from('topic').select('topic_name');
      final topicNames = (categoryResponse as List)
          .map((e) => e['topic_name'] as String)
          .toList();
      categories = ['Tất cả', ...topicNames];

      // Fetch articles
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
              ),
              newspaper(is_vn)
            ),
            article_keyword (
              keyword:keyword_id (
                keyword_name
              )
            )
          ''')
          .order('article_id', ascending: false);

      _feedItems = (articleResponse as List)
          .map((json) => FeedItem.fromJson(json))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Lỗi khi tải dữ liệu: $e');
    }
  }

  void selectCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  List<FeedItem> get filteredFeedItems {
    if (selectedCategory == 'Tất cả') {
      return _feedItems;
    }
    return _feedItems
        .where((item) => item.category == selectedCategory)
        .toList();
  }
}
