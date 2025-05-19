import 'package:rss_feed/services/supabase_service.dart';
import 'package:rss_feed/controllers/news_controller.dart';
import 'package:rss_feed/row_row_row_generated/tables/topic.row.dart';

class TopicRepository {
  static final TopicRepository _instance = TopicRepository._internal();

  factory TopicRepository() {
    return _instance;
  }

  TopicRepository._internal();
  final _supabase = SupabaseService.instance.client;

  /// Lấy danh sách các chủ đề nổi bật
  Future<List<Topic>> getPopularTopics({int limit = 10}) async {
    try {
      // Truy vấn để lấy các chủ đề nổi bật
      final response = await _supabase
          .from('topic')
          .select()
          .limit(limit);

      // Chuyển đổi từ response sang TopicRow
      final topicRows = response.map((json) => TopicRow.fromJson(json)).toList();

      // Chuyển đổi từ TopicRow sang Topic model (với các icon mặc định)
      return topicRows.map((row) => _convertRowToTopic(row)).toList();
    } catch (e) {
      print('Error fetching popular topics: $e');
      return [];
    }
  }

  /// Tìm kiếm chủ đề theo tên
  Future<List<Topic>> searchTopics(String query) async {
    try {
      final response = await _supabase
          .from('topic')
          .select()
          .filter('topic_name', 'ilike', '%$query%')
          .order('topic_name');

      final topicRows = response.map((json) => TopicRow.fromJson(json)).toList();
      return topicRows.map((row) => _convertRowToTopic(row)).toList();
    } catch (e) {
      print('Error searching topics: $e');
      return [];
    }
  }

  /// Lấy danh sách các tin từ chủ đề, đầu báo
  Future<List<Map<String, dynamic>>> getArticlesByTopicAndNewspaper(
      int topicId, int? newspaperId, {int limit = 20}) async {
    try {
      // Cách tiếp cận mới: Đầu tiên lấy tất cả article_id có topic_id tương ứng
      final articleTopics = await _supabase
          .from('article_topic')
          .select('article_id')
          .filter('topic_id', 'eq', topicId);

      // Lấy danh sách article_ids
      final List<int> articleIds = articleTopics.map<int>((item) => item['article_id'] as int).toList();

      // Nếu không có bài viết nào, trả về danh sách rỗng
      if (articleIds.isEmpty) {
        return [];
      }

      // Truy vấn các bài viết với các id đã lấy được
      var query = _supabase
          .from('article')
          .select('*')
          .contains('article_id', articleIds);

      // Nếu có newspaperId, lọc thêm theo đầu báo
      if (newspaperId != null) {
        query = query.filter('newspaper_id', 'eq', newspaperId);
      }

      // Sắp xếp và giới hạn kết quả
      final response = await query.order('created_at', ascending: false).limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching articles by topic and newspaper: $e');
      return [];
    }
  }

  /// Lấy chủ đề theo đầu báo
  Future<List<Topic>> getTopicsByNewspaper(int newspaperId) async {
    try {
      // Phương pháp thay thế không sử dụng RPC và execute
      // Bước 1: Lấy tất cả article_id của newspaper_id
      final articles = await _supabase
          .from('article')
          .select('article_id')
          .filter('newspaper_id', 'eq', newspaperId);

      // Lấy danh sách article_ids
      final List<int> articleIds = articles.map<int>((item) => item['article_id'] as int).toList();

      // Nếu không có bài viết nào, trả về danh sách rỗng
      if (articleIds.isEmpty) {
        return [];
      }

      // Bước 2: Lấy topic_id từ article_topic dựa trên article_ids
      final articleTopics = await _supabase
          .from('article_topic')
          .select('topic_id')
          .contains('article_id', articleIds);

      // Lấy danh sách topic_ids (duy nhất)
      final Set<int> uniqueTopicIds = articleTopics.map<int>((item) => item['topic_id'] as int).toSet();

      // Nếu không có topic nào, trả về danh sách rỗng
      if (uniqueTopicIds.isEmpty) {
        return [];
      }

      // Bước 3: Lấy thông tin chi tiết của các topic
      final topics = await _supabase
          .from('topic')
          .select()
          .contains('topic_id', uniqueTopicIds.toList());

      final topicRows = topics.map((json) => TopicRow.fromJson(json)).toList();
      return topicRows.map((row) => _convertRowToTopic(row)).toList();
    } catch (e) {
      print('Error fetching topics by newspaper: $e');
      return [];
    }
  }

  // Helper method to convert TopicRow to Topic with default icon names
  Topic _convertRowToTopic(TopicRow row) {
    // Gán icon mặc định dựa trên tên chủ đề
    final iconName = _getDefaultIconName(row.topicName.toString());

    return Topic(
      id: row.topicId,
      name: row.topicName.toString(),
      iconName: iconName,
    );
  }

  // Helper function để chọn icon mặc định dựa trên tên chủ đề
  String _getDefaultIconName(String topicName) {
    final name = topicName.toLowerCase();

    if (name.contains('thời sự') || name.contains('tin tức')) {
      return 'newspaper';
    } else if (name.contains('thể thao') || name.contains('sport')) {
      return 'sports_soccer';
    } else if (name.contains('giải trí') || name.contains('entertainment')) {
      return 'movie';
    } else if (name.contains('kinh doanh') || name.contains('business')) {
      return 'business';
    } else if (name.contains('công nghệ') || name.contains('tech')) {
      return 'computer';
    } else {
      return 'topic'; // Icon mặc định
    }
  }
}