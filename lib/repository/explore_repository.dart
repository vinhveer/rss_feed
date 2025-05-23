import 'package:supabase_flutter/supabase_flutter.dart';
import '../row_row_row/tables/newspaper.row.dart';
import '../row_row_row/tables/topic.row.dart';
import '../row_row_row/tables/article.row.dart';

class ExploreRepository {
  final _supabase = Supabase.instance.client;

  /// Lấy danh sách 8 đầu báo nổi bật
  Future<List<NewspaperRow>> getFeaturedNewspapers() async {
    try {
      final response = await _supabase
          .from(NewspaperRow.table)
          .select()
          .order('newspaper_id', ascending: true)
          .limit(8);

      return response.map<NewspaperRow>((json) => NewspaperRow.fromJson(json)).toList();
    } catch (e) {
      print('Error getting featured newspapers: $e');
      rethrow;
    }
  }

  /// Lấy danh sách 10 chủ đề nổi bật
  Future<List<TopicRow>> getFeaturedTopics() async {
    try {
      final response = await _supabase
          .from(TopicRow.table)
          .select()
          .order('topic_id', ascending: true)
          .limit(10);

      return response.map<TopicRow>((json) => TopicRow.fromJson(json)).toList();
    } catch (e) {
      print('Error getting featured topics: $e');
      rethrow;
    }
  }

  /// Tìm kiếm bài viết
  Future<List<ArticleRow>> searchArticles(String query) async {
    try {
      final response = await _supabase
          .from(ArticleRow.table)
          .select()
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('pub_date', ascending: false)
          .limit(20);

      return response.map<ArticleRow>((json) => ArticleRow.fromJson(json)).toList();
    } catch (e) {
      print('Error searching articles: $e');
      rethrow;
    }
  }

  /// Tìm kiếm chủ đề
  Future<List<TopicRow>> searchTopics(String query) async {
    try {
      final response = await _supabase
          .from(TopicRow.table)
          .select()
          .ilike('topic_name', '%$query%')
          .order('topic_id', ascending: true)
          .limit(10);

      return response.map<TopicRow>((json) => TopicRow.fromJson(json)).toList();
    } catch (e) {
      print('Error searching topics: $e');
      rethrow;
    }
  }

  /// Tìm kiếm đầu báo
  Future<List<NewspaperRow>> searchNewspapers(String query) async {
    try {
      final response = await _supabase
          .from(NewspaperRow.table)
          .select()
          .ilike('newspaper_name', '%$query%')
          .order('newspaper_id', ascending: true)
          .limit(10);

      return response.map<NewspaperRow>((json) => NewspaperRow.fromJson(json)).toList();
    } catch (e) {
      print('Error searching newspapers: $e');
      rethrow;
    }
  }
} 