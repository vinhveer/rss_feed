import 'package:rss_feed/row_row_row/tables/favourite_article.row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavouriteRepository {
  final _client = Supabase.instance.client;
  static const _tableName = 'favourite_article';

  /// Load all favorites for the current user
  Future<List<FavouriteArticleRow>> loadFavourites() async {
    try {
      // Get current user's ID from the client
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from(_tableName)
          .select('user_id, article_id, article(pub_date, title, link, image_url, description)')
          .eq('user_id', userId)
          .order('article(pub_date)', ascending: false);

      return response.map<FavouriteArticleRow>((map) => FavouriteArticleRow.fromJson(map)).toList();
    } catch (e) {
      print('Error loading favourites: $e');
      rethrow;
    }
  }

  /// Load a specific favorite by articleId for the current user
  Future<FavouriteArticleRow?> loadFavouriteByArticleId(int articleId) async {
    try {
      // Get current user's ID from the client
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from(_tableName)
          .select('user_id, article_id, article(pub_date, title, link, image_url, description)')
          .eq('article_id', articleId)
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        return FavouriteArticleRow.fromJson(response);
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

      final item = FavouriteArticleRow(
        userId: userId,
        articleId: articleId,
      );

      await _client
          .from(_tableName)
          .insert(item.toJson());
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