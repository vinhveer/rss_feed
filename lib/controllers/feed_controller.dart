import 'package:flutter/material.dart';
import 'package:rss_feed/models/feed_item_local.dart';

class FeedController extends ChangeNotifier {
  int _selectedCategoryIndex = 0;
  final List<String> categories = [
    'Tất cả',
    'Nóng',
    'Thể thao',
    'Giải trí',
    'Khoa học',
    'Âm nhạc',
    'Trò chơi',
    'Tin tức',
    'Công nghệ',
  ];

  final List<FeedItem> _feedItems = [
    FeedItem(
      title: 'NASA phát hiện hành tinh mới có khả năng chứa sự sống',
      source: 'Khoa học Việt Nam',
      timeAgo: '2 giờ trước',
      imageUrl: 'assets/images/planet.jpg',
      category: 'Khoa học',
    ),
    FeedItem(
      title: 'Giải vô địch bóng đá thế giới 2026 sẽ được tổ chức tại đâu?',
      source: 'Thể thao 24h',
      timeAgo: '5 giờ trước',
      imageUrl: 'assets/images/football.jpg',
      category: 'Thể thao',
    ),
    FeedItem(
      title: 'Album mới của Taylor Swift phá vỡ kỷ lục trên các nền tảng nghe nhạc',
      source: 'Âm nhạc Plus',
      timeAgo: '1 ngày trước',
      imageUrl: 'assets/images/music.jpg',
      category: 'Giải trí',
    ),
    FeedItem(
      title: 'Xu hướng AI mới nhất năm 2025 bạn cần biết',
      source: 'Tech Review',
      timeAgo: '3 giờ trước',
      imageUrl: 'assets/images/ai.jpg',
      category: 'Công nghệ',
    ),
    FeedItem(
      title: 'Top 10 điểm du lịch hot nhất mùa hè 2025',
      source: 'Travel & Life',
      timeAgo: '6 giờ trước',
      imageUrl: 'assets/images/travel.jpg',
      category: 'Nóng',
    ),
  ];

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

  // Methods
  void selectCategory(int index) {
    if (index != _selectedCategoryIndex && index >= 0 && index < categories.length) {
      _selectedCategoryIndex = index;
      notifyListeners();
    }
  }

  // Method to add new feed items (for future use)
  void addFeedItem(FeedItem item) {
    _feedItems.add(item);
    notifyListeners();
  }

  // Method to refresh feed with new data (for future use)
  Future<void> refreshFeed() async {
    // Here you would typically fetch new data from an API
    // For now just simulate a delay
    await Future.delayed(const Duration(seconds: 1));
    notifyListeners();
  }
}