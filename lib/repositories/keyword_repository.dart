import 'package:supabase_flutter/supabase_flutter.dart';
import '../row_row_row/tables/keyword.row.dart';
import '../row_row_row/tables/favourite_keyword.row.dart';
import '../services/local_storage_service.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';

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
      final keywords = await getKeywordsForArticle(articleId);
      if (keywords.isEmpty) return;

      print('Adding ${keywords.length} keywords for article $articleId');
      await _addKeywordsToLocalStorage(keywords, articleId);

      // Sync lên cloud
      await _syncToCloud();
    } catch (e) {
      print('Error adding keywords to storage: $e');
    }
  }

  /// Helper method để add keywords vào local storage
  Future<void> _addKeywordsToLocalStorage(
    List<KeywordRow> keywords,
    int articleId,
  ) async {
    final existingKeywords = await _getLocalKeywords();
    final timestamp = DateTime.now().toIso8601String();

    for (var keyword in keywords) {
      final existingIndex = existingKeywords.indexWhere(
        (k) => k['keyword']['keyword_id'] == keyword.keywordId,
      );

      if (existingIndex >= 0) {
        // Update existing keyword
        existingKeywords[existingIndex]['usage_count'] =
            (existingKeywords[existingIndex]['usage_count'] ?? 1) + 1;
        existingKeywords[existingIndex]['last_used'] = timestamp;
      } else {
        // Add new keyword
        existingKeywords.add({
          'article_id': articleId,
          'keyword': keyword.toJson(),
          'timestamp': timestamp,
          'last_used': timestamp,
          'usage_count': 1,
        });
      }
    }

    await _saveLocalKeywords(existingKeywords);
  }

  /// Get keywords from local storage
  Future<List<Map<String, dynamic>>> getKeywordsFromStorage() async {
    try {
      final localKeywords = await _getLocalKeywords();

      // Nếu local trống, tải từ cloud xuống
      if (localKeywords.isEmpty) {
        print('Local keywords empty, loading from cloud...');
        await _loadFromCloud();
        final updatedKeywords = await _getLocalKeywords();

        // Nếu cả local và cloud đều trống, điều hướng đến trang chọn chủ đề
        if (updatedKeywords.isEmpty) {
          print('No keywords found in both local and cloud storage');
          Get.find<AppController>().goToPageChooseTopic();
        }

        return updatedKeywords;
      }

      return localKeywords;
    } catch (e) {
      print('Error getting keywords from storage: $e');
      return [];
    }
  }

  /// Lưu/favourite 1 từ khóa theo tên, đồng thời lưu user_id vào bảng favourite_keyword
  Future<void> saveKeywordByName(String keywordName) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // 1️⃣ Tìm hoặc tạo keyword
    final existing =
        await Supabase.instance.client
            .from(KeywordRow.table)
            .select('keyword_id')
            .eq(KeywordRow.field.keywordName, keywordName)
            .maybeSingle();

    late final int keywordId;
    if (existing != null && existing['keyword_id'] != null) {
      keywordId = existing['keyword_id'] as int;
    } else {
      final created = await KeywordRow.create(keywordName: keywordName);
      keywordId = created.keywordId;
    }

    // 2️⃣ Thêm vào favourite_keyword, tránh duplicate
    await Supabase.instance.client
        .from(FavouriteKeywordRow.table)
        .upsert(
          {
            FavouriteKeywordRow.field.userId: userId,
            FavouriteKeywordRow.field.keywordId: keywordId,
          },
          onConflict: '${FavouriteKeywordRow.field.userId},${FavouriteKeywordRow.field.keywordId}',
        );

    // 3️⃣ Lưu vào localStorage
    final localKeywords = await _getLocalKeywords();
    final timestamp = DateTime.now().toIso8601String();
    
    // Kiểm tra xem keyword đã tồn tại trong localStorage chưa
    final existingIndex = localKeywords.indexWhere(
      (k) => k['keyword']['keyword_id'] == keywordId,
    );

    if (existingIndex >= 0) {
      // Update existing keyword
      localKeywords[existingIndex]['usage_count'] = 
          (localKeywords[existingIndex]['usage_count'] ?? 1) + 1;
      localKeywords[existingIndex]['last_used'] = timestamp;
    } else {
      // Add new keyword
      localKeywords.add({
        'keyword': {
          'keyword_id': keywordId,
          'keyword_name': keywordName,
        },
        'timestamp': timestamp,
        'last_used': timestamp,
        'usage_count': 1,
      });
    }

    // Lưu lại vào localStorage với limit và sort
    await _saveLocalKeywords(localKeywords);

    print('✅ Keyword "$keywordName" saved for user $userId');
  }

  /// Load keywords từ cloud xuống local
  Future<void> _loadFromCloud() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        print('No user logged in, cannot load from cloud');
        return;
      }

      final cloudKeywords = await _getCloudKeywords(userId);
      if (cloudKeywords.isEmpty) {
        print('No keywords found in cloud');
        return;
      }

      print('Loading ${cloudKeywords.length} keywords from cloud');

      final timestamp = DateTime.now().toIso8601String();
      final localKeywords =
          cloudKeywords
              .map(
                (keyword) => {
                  'keyword': keyword.toJson(),
                  'timestamp': timestamp,
                  'last_used': timestamp,
                  'usage_count': 1,
                },
              )
              .toList();

      await _saveLocalKeywords(localKeywords);
      print('Successfully loaded ${localKeywords.length} keywords from cloud');
    } catch (e) {
      print('Error loading from cloud: $e');
    }
  }

  /// Sync keywords lên cloud
  Future<void> _syncToCloud() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        print('No user logged in, cannot sync to cloud');
        return;
      }

      final localKeywords = await _getLocalKeywords();
      final cloudKeywords = await _getCloudKeywords(userId);

      final cloudKeywordIds = cloudKeywords.map((k) => k.keywordId).toSet();
      final localKeywordIds =
          localKeywords.map((k) => k['keyword']['keyword_id'] as int).toSet();

      // Tìm keywords chỉ có ở local (cần push lên cloud)
      final keywordsToSync = localKeywordIds.difference(cloudKeywordIds);

      if (keywordsToSync.isEmpty) {
        print('All keywords already synced to cloud');
        return;
      }

      print('Syncing ${keywordsToSync.length} keywords to cloud');

      // Push từng keyword lên cloud
      for (final keywordId in keywordsToSync) {
        try {
          await FavouriteKeywordRow.create(
            userId: userId,
            keywordId: keywordId,
          );
        } catch (e) {
          print('Error syncing keyword $keywordId: $e');
        }
      }

      print('Successfully synced keywords to cloud');
    } catch (e) {
      print('Error syncing to cloud: $e');
    }
  }

  /// Get cloud keywords
  Future<List<KeywordRow>> _getCloudKeywords(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from(FavouriteKeywordRow.table)
          .select('keyword:keyword_id(*)')
          .eq(FavouriteKeywordRow.field.userId, userId);

      return (response as List)
          .map((json) => KeywordRow.fromJson(json['keyword']))
          .toList();
    } catch (e) {
      print('Error getting cloud keywords: $e');
      return [];
    }
  }

  /// Get local keywords helper
  Future<List<Map<String, dynamic>>> _getLocalKeywords() async {
    final List<dynamic> storedData =
        _storage.get<List<dynamic>>(_storageKey) ?? [];
    return storedData.cast<Map<String, dynamic>>();
  }

  /// Save local keywords với limit và sort
  Future<void> _saveLocalKeywords(List<Map<String, dynamic>> keywords) async {
    // Remove duplicates
    final uniqueKeywords = _removeDuplicates(keywords);

    // Sort by usage count và timestamp
    uniqueKeywords.sort((a, b) {
      final usageA = a['usage_count'] ?? 1;
      final usageB = b['usage_count'] ?? 1;

      if (usageA != usageB) {
        return usageB.compareTo(usageA);
      }

      return DateTime.parse(
        b['timestamp'],
      ).compareTo(DateTime.parse(a['timestamp']));
    });

    // Apply limit
    final limitedKeywords =
        uniqueKeywords.length > _maxKeywords
            ? uniqueKeywords.sublist(0, _maxKeywords)
            : uniqueKeywords;

    await _storage.set(_storageKey, limitedKeywords);

    if (keywords.length != limitedKeywords.length) {
      print(
        'Limited keywords: ${keywords.length} -> ${limitedKeywords.length}',
      );
    }
  }

  /// Remove duplicate keywords
  List<Map<String, dynamic>> _removeDuplicates(
    List<Map<String, dynamic>> keywords,
  ) {
    final Map<int, Map<String, dynamic>> uniqueMap = {};

    for (final keyword in keywords) {
      final keywordId = keyword['keyword']['keyword_id'] as int;
      final usageCount = keyword['usage_count'] ?? 1;

      if (!uniqueMap.containsKey(keywordId) ||
          (uniqueMap[keywordId]!['usage_count'] ?? 1) < usageCount) {
        uniqueMap[keywordId] = keyword;
      }
    }

    return uniqueMap.values.toList();
  }

  /// Manual sync - force sync both ways
  Future<void> manualSync() async {
    try {
      print('Starting manual sync...');

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        print('No user logged in');
        return;
      }

      // 1. Sync local keywords lên cloud
      await _syncToCloud();

      // 2. Load cloud keywords xuống và merge với local
      final cloudKeywords = await _getCloudKeywords(userId);
      final localKeywords = await _getLocalKeywords();

      final localKeywordIds =
          localKeywords.map((k) => k['keyword']['keyword_id'] as int).toSet();

      // Tìm keywords chỉ có ở cloud
      final cloudOnlyKeywords =
          cloudKeywords
              .where((k) => !localKeywordIds.contains(k.keywordId))
              .toList();

      if (cloudOnlyKeywords.isNotEmpty) {
        print(
          'Adding ${cloudOnlyKeywords.length} keywords from cloud to local',
        );

        final timestamp = DateTime.now().toIso8601String();
        final newLocalKeywords = List<Map<String, dynamic>>.from(localKeywords);

        for (final keyword in cloudOnlyKeywords) {
          newLocalKeywords.add({
            'keyword': keyword.toJson(),
            'timestamp': timestamp,
            'last_used': timestamp,
            'usage_count': 1,
          });
        }

        await _saveLocalKeywords(newLocalKeywords);
      }

      print('Manual sync completed');
    } catch (e) {
      print('Error during manual sync: $e');
    }
  }

  /// Clear local cache
  Future<void> clearLocalKeywords() async {
    await _storage.set(_storageKey, null);
    print('Local keywords cleared');
  }

  /// Get simple stats
  Future<Map<String, dynamic>> getStats() async {
    final keywords = await _getLocalKeywords();

    return {
      'total_keywords': keywords.length,
      'total_usage': keywords.fold<int>(
        0,
        (sum, k) => sum + ((k['usage_count'] ?? 1) as int),
      ),
    };
  }
}
