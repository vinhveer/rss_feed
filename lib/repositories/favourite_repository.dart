import 'package:rss_feed/types/favourite_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavouriteRepository {
  final _client = Supabase.instance.client;
  static const _tableName = 'favourite_article';

  /// Load favorites with pagination, sorting and search
  /// [offset] - Starting position (for pagination)
  /// [limit] - Number of items to load
  /// [searchQuery] - Optional search term to filter by title
  /// [sortBy] - Field to sort by ('pub_date' or 'title')
  /// [sortAscending] - Sort direction
  Future<List<FavouriteItem>> loadFavourites({
    int offset = 0,
    int limit = 20,
    String? searchQuery,
    String sortBy = 'pub_date',
    bool sortAscending = false,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Query từ bảng article và JOIN với favourite_article
      var query = _client
          .from('article')
          .select('''
            article_id,
            title,
            pub_date,
            link,
            image_url,
            description,
            favourite_article!inner(user_id)
          ''')
          .eq('favourite_article.user_id', userId);

      // Apply search if query provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('title', '%$searchQuery%');
      }

      // Apply sorting and pagination
      final response = await query
          .order(sortBy, ascending: sortAscending)
          .range(offset, offset + limit - 1);

      return response.map<FavouriteItem>((map) => FavouriteItem.fromMapDirect(map, userId)).toList();
    } catch (e) {
      print('Error loading favourites: $e');
      rethrow;
    }
  }

  /// Get total count of favorites for current user
  Future<int> getFavouritesCount({String? searchQuery}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      var query = _client
          .from('article')
          .select('article_id, title, favourite_article!inner(user_id)')
          .eq('favourite_article.user_id', userId);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('title', '%$searchQuery%');
      }

      final response = await query;
      return response.length;
    } catch (e) {
      print('Error getting favourites count: $e');
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
          .select('''
            article_id,
            user_id,
            article:article_id (
              title,
              pub_date,
              link,
              image_url,
              description
            )
          ''')
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