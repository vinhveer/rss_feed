import 'package:rss_feed/services/supabase_service.dart';
import 'package:rss_feed/row_row_row_generated/tables/newspaper.row.dart';

import '../models/newspaper_local.dart';

class NewspaperRepository {
  static final NewspaperRepository _instance = NewspaperRepository._internal();

  factory NewspaperRepository() {
    return _instance;
  }
  NewspaperRepository._internal();
  final _supabase = SupabaseService.instance.client;

  /// Lấy danh sách các đầu báo nổi bật (có nhiều bài nhất)
  Future<List<Newspaper>> getPopularNewspapers({int limit = 10}) async {
    try {
      // Lấy dữ liệu từ Supabase
      final response = await _supabase
          .from('newspaper')
          .select()
          .limit(limit);

      // Chuyển đổi từ response sang NewspaperRow
      final newspaperRows = response.map((json) => NewspaperRow.fromJson(json)).toList();

      // Chuyển đổi từ NewspaperRow sang Newspaper (model sử dụng trong Controller)
      return newspaperRows.map((row) => _convertRowToNewspaper(row)).toList();
    } catch (e) {
      print('Error fetching popular newspapers: $e');
      return [];
    }
  }

  /// Tìm kiếm đầu báo theo tên
  Future<List<Newspaper>> searchNewspapers(String query) async {
    try {
      final response = await _supabase
          .from('newspaper')
          .select()
          .filter('newspaper_name', 'ilike', '%$query%')
          .order('newspaper_name');

      final newspaperRows = response.map((json) => NewspaperRow.fromJson(json)).toList();
      return newspaperRows.map((row) => _convertRowToNewspaper(row)).toList();
    } catch (e) {
      print('Error searching newspapers: $e');
      return [];
    }
  }
  /// Lấy danh sách tin từ đầu báo
  Future<List<Map<String, dynamic>>> getArticlesByNewspaper(int newspaperId, {int limit = 20}) async {
    try {
      // Giả sử có bảng article liên kết với newspaper
      final response = await _supabase
          .from('article')
          .select('*')
          .filter('newspaper_id', 'eq', newspaperId)
          .order('created_at', ascending: false)
          .limit(limit);

      // Đảm bảo trả về List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching articles by newspaper: $e');
      return [];
    }
  }

  Newspaper _convertRowToNewspaper(NewspaperRow row) {
    return Newspaper(
      id: row.newspaperId,
      name: row.newspaperName.toString(),
    );
  }
}