import 'package:supabase_flutter/supabase_flutter.dart';

class FavouriteItem {
  final int id;
  final String userId;
  final String title;
  final String? description;
  final String? imageUrl;
  final String link;
  final DateTime pubDate;

  FavouriteItem({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.imageUrl,
    required this.link,
    required this.pubDate,
  });

  factory FavouriteItem.fromMap(Map<String, dynamic> map) {
    final article = map['article'] ?? {};

    return FavouriteItem(
      id: map['article_id'] as int,
      userId: map['user_id'] as String,
      title: article['title'] as String? ?? '',
      description: article['description'] as String?,
      imageUrl: article['image_url'] as String?,
      link: article['link'] as String? ?? '',
      pubDate: DateTime.parse(article['pub_date'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'article_id': id,
    };
  }
}

class FavouriteController {
  final String userId;
  final List<FavouriteItem> _favourites = [];
  final List<FavouriteItem> _selectedItems = [];
  bool _isLoading = false;
  bool _isSelectMode = false;

  FavouriteController({required this.userId});

  List<FavouriteItem> get favourites => _favourites;
  List<FavouriteItem> get selectedItems => _selectedItems;
  bool get isLoading => _isLoading;
  bool get isSelectMode => _isSelectMode;

  final _client = Supabase.instance.client;

  /// Load toàn bộ mục yêu thích theo userId
  Future<void> loadFavourites() async {
    _isLoading = true;

    try {
      final response = await _client
          .from('favourite_article')
          .select('user_id, article_id, article(pub_date, title, link, image_url, description)')
          .eq('user_id', userId)
          .order('article(pub_date)', ascending: false);

      _favourites.clear();
      for (final map in response) {
        _favourites.add(FavouriteItem.fromMap(map));
      }
    } catch (e) {
      // Handle errors appropriately
      print('Error loading favourites: $e');
    } finally {
      _isLoading = false;
    }
  }

  /// Load theo ID cụ thể của bài viết
  Future<FavouriteItem?> loadFavouriteByArticleId(int articleId) async {
    _isLoading = true;

    try {
      final response = await _client
          .from('favourite_article')
          .select('user_id, article_id, article(pub_date, title, link, image_url, description)')
          .eq('article_id', articleId)
          .eq('user_id', userId)
          .maybeSingle();

      _isLoading = false;

      if (response != null) {
        return FavouriteItem.fromMap(response);
      }
      return null;
    } catch (e) {
      _isLoading = false;
      print('Error loading favourite by article ID: $e');
      return null;
    }
  }

  /// Xóa 1 mục
  Future<void> deleteFavouriteItem(FavouriteItem item) async {
    try {
      await _client
          .from('favourite_article')
          .delete()
          .eq('article_id', item.id)
          .eq('user_id', userId);

      _favourites.removeWhere((f) => f.id == item.id);
    } catch (e) {
      print('Error deleting favourite item: $e');
      // Re-throw or handle as needed
      rethrow;
    }
  }

  /// Hoàn tác xóa
  Future<void> undoDelete(FavouriteItem item) async {
    try {
      await _client
          .from('favourite_article')
          .insert(item.toMap());

      // Reload the item to get the full data with article details
      final insertedItem = await loadFavouriteByArticleId(item.id);

      if (insertedItem != null && !_favourites.any((f) => f.id == item.id)) {
        _favourites.insert(0, insertedItem);
      }
    } catch (e) {
      print('Error undoing delete: $e');
      // Re-throw or handle as needed
      rethrow;
    }
  }

  /// Chế độ chọn
  void toggleItemSelection(FavouriteItem item) {
    final index = _selectedItems.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      _selectedItems.removeAt(index);
    } else {
      _selectedItems.add(item);
    }
  }

  void enableSelectMode() {
    _isSelectMode = true;
    _selectedItems.clear();
  }

  void cancelSelection() {
    _isSelectMode = false;
    _selectedItems.clear();
  }

  /// Xóa nhiều mục đã chọn
  Future<void> deleteSelected() async {
    if (_selectedItems.isEmpty) return;

    try {
      final ids = _selectedItems.map((e) => e.id).toList();
      await _client
          .from('favourite_article')
          .delete()
          .inFilter('article_id', ids)
          .eq('user_id', userId);

      _favourites.removeWhere((f) => ids.contains(f.id));
      cancelSelection();
    } catch (e) {
      print('Error deleting selected items: $e');
      // Re-throw or handle as needed
      rethrow;
    }
  }

  bool isSelected(FavouriteItem item) {
    return _selectedItems.any((i) => i.id == item.id);
  }
}