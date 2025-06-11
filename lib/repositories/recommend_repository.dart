import 'dart:convert';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../types/recommend_article.dart';
import '../types/recommend_keyword.dart';

class Article {
  final int articleId;
  final String title;
  final String link;
  final String imageUrl;
  final String description;
  final DateTime pubDate;
  final int rssId;

  Article({
    required this.articleId,
    required this.title,
    required this.link,
    required this.imageUrl,
    required this.description,
    required this.pubDate,
    required this.rssId,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      articleId: json['article_id'],
      title: json['title'],
      link: json['link'],
      imageUrl: json['image_url'],
      description: json['description'],
      pubDate: DateTime.parse(json['pub_date']),
      rssId: json['rss_id'],
    );
  }
}

class Keyword {
  final int keywordId;
  final String keywordName;
  final int articleCount;

  Keyword({
    required this.keywordId,
    required this.keywordName,
    required this.articleCount,
  });

  factory Keyword.fromJson(Map<String, dynamic> json) {
    return Keyword(
      keywordId: json['keyword_id'],
      keywordName: json['keyword_name'],
      articleCount: json['article_count'],
    );
  }
}

class RecommendRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getHotArticles({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _apiService.get(
        '/api/v1/recommend/hot-articles?page=$page&page_size=$pageSize',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = (data['articles'] as List)
            .map((article) => RecommendArticle.fromJson(article))
            .toList();

        return {
          'articles': articles,
          'total': data['total'],
          'page': data['page'],
          'page_size': data['page_size'],
        };
      } else {
        throw Exception('Failed to load hot articles');
      }
    } catch (e) {
      Get.log('Error getting hot articles: $e');
      rethrow;
    }
  }

  Future<List<RecommendKeyword>> getHotKeywords() async {
    try {
      final response = await _apiService.get(
        '/api/v1/recommend/hot-keywords',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['keywords'] as List)
            .map((keyword) => RecommendKeyword.fromJson(keyword))
            .toList();
      } else {
        throw Exception('Failed to load hot keywords');
      }
    } catch (e) {
      Get.log('Error getting hot keywords: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getArticlesByKeywords({
    required List<String> keywords,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final queryParams = keywords
          .map((keyword) => 'keywords=${Uri.encodeComponent(keyword)}')
          .join('&');
      
      final response = await _apiService.get(
        '/api/v1/recommend/by-keywords?$queryParams&page=$page&page_size=$pageSize',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = (data['articles'] as List)
            .map((article) => RecommendArticle.fromJson(article))
            .toList();

        return {
          'articles': articles,
          'total': data['total'],
          'page': data['page'],
          'page_size': data['page_size'],
        };
      } else {
        throw Exception('Failed to load articles by keywords');
      }
    } catch (e) {
      Get.log('Error getting articles by keywords: $e');
      rethrow;
    }
  }

  /// Get related articles by keyword name
  Future<Map<String, dynamic>> getRelatedArticlesByKeywordName({
    required String keywordName,
    int limit = 10,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _apiService.get(
        '/api/v1/recommend/related-keywords-by-name?name=${Uri.encodeComponent(keywordName)}&limit=$limit&page=$page&page_size=$pageSize',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load related articles');
      }
    } catch (e) {
      Get.log('Error getting related articles: $e');
      rethrow;
    }
  }

  /// Get related articles for an article
  Future<List<RecommendArticle>> getRelatedArticlesForArticle(int articleId) async {
    try {
      final response = await _apiService.get(
        '/api/v1/recommend/related-articles/$articleId',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['articles'] as List)
            .map((article) => RecommendArticle.fromJson(article))
            .toList();
      } else {
        throw Exception('Failed to load related articles');
      }
    } catch (e) {
      Get.log('Error getting related articles: $e');
      rethrow;
    }
  }
} 