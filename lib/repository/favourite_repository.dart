import 'package:rss_feed/models/favourite_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavouriteRepository {
  final _client = Supabase.instance.client;
  static const _tableName = 'favourite_article';

  /// Load all favorites for the current user
  Future<List<FavouriteItem>> loadFavourites() async {
    try {
      // Get current user's ID from the client
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from(_tableName)
          .select('article_id, user_id, article(pub_date, title, link, image_url, description)')
          .eq('user_id', userId)
          .order('article(pub_date)', ascending: false);

      return response.map<FavouriteItem>((map) => FavouriteItem.fromMap(map)).toList();
    } catch (e) {
      print('Error loading favourites: $e');
      rethrow;
    }
  }

  /// Load a specific favorite by articleId for the current user
  Future<FavouriteItem?> loadFavouriteByArticleId(int articleId) async {
    try {
      // Get current user's ID from the client
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from(_tableName)
          .select('article_id, user_id, article(pub_date, title, link, image_url, description)')
          .eq('article_id', articleId)
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        return FavouriteItem.fromMap(response);
      }
      return null;
    } catch (e) {
      print('Error loading favourite by article ID: $e');
      rethrow;
    }
  }

  /// Delete a favorite item
  Future<void> deleteFavouriteItem(int articleId) async {
    try {
      // Get current user's ID from the client
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _client
          .from(_tableName)
          .delete()
          .eq('article_id', articleId)
          .eq('user_id', userId);
    } catch (e) {
      print('Error deleting favourite item: $e');
      rethrow;
    }
  }

  /// Create/restore a favorite item
  Future<void> createFavouriteItem(int articleId) async {
    try {
      // Get current user's ID from the client
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final item = FavouriteItem(
        id: articleId,
        userId: userId,
        title: '', // These will be populated from the article table
        link: '',
        pubDate: DateTime.now(),
      );

      await _client
          .from(_tableName)
          .insert(item.toMap());
    } catch (e) {
      print('Error creating/restoring favourite item: $e');
      rethrow;
    }
  }

  /// Delete multiple favorites by articleIds
  Future<void> deleteMultipleFavourites(List<int> articleIds) async {
    if (articleIds.isEmpty) return;

    try {
      // Get current user's ID from the client
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _client
          .from(_tableName)
          .delete()
          .inFilter('article_id', articleIds)
          .eq('user_id', userId);
    } catch (e) {
      print('Error deleting selected items: $e');
      rethrow;
    }
  }
}