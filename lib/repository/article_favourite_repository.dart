import 'package:rss_feed/exceptions/article_favourite_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ArticleFavouriteRepository {
  final _supabase = Supabase.instance.client;

  /// Thêm bài viết yêu thích
  Future<void> addFavourite(int articleId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw ArticleFavouriteException('User is not authenticated');
    }

    await _supabase.from('favourite_article').insert({
      'article_id': articleId,
      'user_id': userId,
    });
  }

  /// Kiểm tra bài viết đã được yêu thích chưa
  Future<bool> checkFavouriteExists(int articleId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final result = await _supabase
        .from('favourite_article')
        .select()
        .eq('article_id', articleId)
        .eq('user_id', userId)
        .maybeSingle();

    return result != null;
  }

  /// Xóa bài viết khỏi danh sách yêu thích
  Future<void> removeFavourite(int articleId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw ArticleFavouriteException('User is not authenticated');
    }

    await _supabase
        .from('favourite_article')
        .delete()
        .eq('article_id', articleId)
        .eq('user_id', userId);
  }
}