import 'dart:convert';
import '../services/api_service.dart';

class ArticleContentRepository {
  final ApiService _apiService = ApiService();

  /// Trích xuất nội dung bài báo từ URL, trả về Map gồm:
  /// title, text, images, pubDate, author
  Future<Map<String, dynamic>?> fetchArticleContent(String articleUrl) async {
    final response = await _apiService.get(
      '/api/v1/extract/extract?url=$articleUrl',
    );

    if (response.statusCode == 200) {
      try {
        return Map<String, dynamic>.from(
          jsonDecode(utf8.decode(response.bodyBytes)) as Map,
        );
      } catch (_) {
        return null;
      }
    }

    return null;
  }
}