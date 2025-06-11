import 'package:supabase_flutter/supabase_flutter.dart';
import '../row_row_row/tables/keyword.row.dart';
import '../row_row_row/tables/favourite_keyword.row.dart';
import '../services/local_storage_service.dart';

class KeywordRepository {
  static final KeywordRepository _instance = KeywordRepository._internal();
  factory KeywordRepository() => _instance;
  KeywordRepository._internal();

  final _storage = LocalStorageService();
  static const String _storageKey = 'article_keywords';
  static const String _favoriteKeywordsKey = 'favorite_keywords';
  static const int _maxKeywords = 25;

  /// Get list of keywords for a specific article
  Future<List<KeywordRow>> getKeywordsForArticle(int articleId) async {
    try {
      // First sync from cloud to ensure we have latest data
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await syncFavoriteKeywordsFromCloud(userId);
      }

      final response = await Supabase.instance.client
          .from('article_keyword')
          .select('keyword:keyword_id(*)')
          .eq('article_id', articleId);
      
      return (response as List)
          .map((json) => KeywordRow.fromJson(json['keyword']))
          .toList();
    } catch (e) {
      print('Error fetching keywords for article: $e');
      return [];
    }
  }

  /// Add keywords to local storage for an article
  Future<void> addKeywordsToStorage(int articleId) async {
    try {
      // First fetch keywords from Supabase
      final keywords = await getKeywordsForArticle(articleId);

      print('Adding ${keywords.length} keywords for article $articleId');

      if (keywords.isEmpty) return;

      // Get existing keywords
      List<Map<String, dynamic>> existingKeywords = 
          _storage.get<List<dynamic>>(_storageKey)?.cast<Map<String, dynamic>>() ?? [];
      
      // Add new keywords
      for (var keyword in keywords) {
        existingKeywords.add({
          'article_id': articleId,
          'keyword': keyword.toJson(),
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      // Sort by timestamp and keep only the latest 25 keywords
      existingKeywords.sort((a, b) => 
          DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));
      
      if (existingKeywords.length > _maxKeywords) {
        existingKeywords = existingKeywords.sublist(0, _maxKeywords);
      }

      // Save back to storage
      await _storage.set(_storageKey, existingKeywords);

      // Sync to cloud if user is logged in
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await syncFavoriteKeywordsToCloud(userId);
      }
    } catch (e) {
      print('Error adding keywords to storage: $e');
    }
  }

  /// Get list of keywords from local storage
  List<Map<String, dynamic>> getKeywordsFromStorage() {
    try {
      // First sync from cloud to ensure we have latest data
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        syncFavoriteKeywordsFromCloud(userId);
      }

      final List<dynamic> storedData = _storage.get<List<dynamic>>(_storageKey) ?? [];
      return storedData.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting keywords from storage: $e');
      return [];
    }
  }

  /// Sync favorite keywords from cloud to local storage
  Future<void> syncFavoriteKeywordsFromCloud(String userId) async {
    try {
      // Get favorite keywords from cloud
      final response = await Supabase.instance.client
          .from(FavouriteKeywordRow.table)
          .select('keyword:keyword_id(*)')
          .eq(FavouriteKeywordRow.field.userId, userId);

      if (response == null || response.isEmpty) {
        // If no keywords in cloud, clear local storage
        await _storage.set(_favoriteKeywordsKey, null);
        return;
      }

      // Convert to list of keywords
      final List<KeywordRow> keywords = (response as List)
          .map((json) => KeywordRow.fromJson(json['keyword']))
          .toList();

      // Clear existing local storage
      await _storage.set(_favoriteKeywordsKey, null);

      // Save to local storage
      final List<Map<String, dynamic>> keywordsToStore = keywords
          .map((keyword) => {
                'keyword': keyword.toJson(),
                'timestamp': DateTime.now().toIso8601String(),
              })
          .toList();

      await _storage.set(_favoriteKeywordsKey, keywordsToStore);
    } catch (e) {
      print('Error syncing favorite keywords from cloud: $e');
    }
  }

  /// Sync favorite keywords from local storage to cloud
  Future<void> syncFavoriteKeywordsToCloud(String userId) async {
    try {
      // Get keywords from local storage
      final List<dynamic> storedData = _storage.get<List<dynamic>>(_favoriteKeywordsKey) ?? [];
      final List<Map<String, dynamic>> localKeywords = storedData.cast<Map<String, dynamic>>();

      if (localKeywords.isEmpty) {
        // If no local keywords, clear cloud data
        await Supabase.instance.client
            .from(FavouriteKeywordRow.table)
            .delete()
            .eq(FavouriteKeywordRow.field.userId, userId);
        return;
      }

      // Get existing cloud keywords
      final response = await Supabase.instance.client
          .from(FavouriteKeywordRow.table)
          .select()
          .eq(FavouriteKeywordRow.field.userId, userId);

      final List<FavouriteKeywordRow> cloudKeywords = (response as List)
          .map((json) => FavouriteKeywordRow.fromJson(json))
          .toList();

      // Find keywords to add and remove
      final Set<int> localKeywordIds = localKeywords
          .map((k) => (k['keyword'] as Map<String, dynamic>)['id'] as int)
          .toSet();
      
      final Set<int> cloudKeywordIds = cloudKeywords
          .map((k) => k.keywordId)
          .toSet();

      // Add new keywords
      for (final keywordId in localKeywordIds) {
        if (!cloudKeywordIds.contains(keywordId)) {
          await FavouriteKeywordRow.create(
            userId: userId,
            keywordId: keywordId,
          );
        }
      }

      // Remove keywords that are no longer in local storage
      for (final keywordId in cloudKeywordIds) {
        if (!localKeywordIds.contains(keywordId)) {
          await Supabase.instance.client
              .from(FavouriteKeywordRow.table)
              .delete()
              .eq(FavouriteKeywordRow.field.userId, userId)
              .eq(FavouriteKeywordRow.field.keywordId, keywordId);
        }
      }
    } catch (e) {
      print('Error syncing favorite keywords to cloud: $e');
    }
  }
} 