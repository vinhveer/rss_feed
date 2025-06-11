import 'package:supabase_flutter/supabase_flutter.dart';
import '../row_row_row/tables/keyword.row.dart';
import '../services/local_storage_service.dart';

class KeywordRepository {
  static final KeywordRepository _instance = KeywordRepository._internal();
  factory KeywordRepository() => _instance;
  KeywordRepository._internal();

  final _storage = LocalStorageService();
  static const String _storageKey = 'article_keywords';
  static const int _maxKeywords = 25;

  /// Get list of keywords for a specific article
  Future<List<KeywordRow>> getKeywordsForArticle(int articleId) async {
    try {
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
    } catch (e) {
      print('Error adding keywords to storage: $e');
    }
  }

  /// Get list of keywords from local storage
  List<Map<String, dynamic>> getKeywordsFromStorage() {
    try {
      final List<dynamic> storedData = _storage.get<List<dynamic>>(_storageKey) ?? [];
      return storedData.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting keywords from storage: $e');
      return [];
    }
  }
} 