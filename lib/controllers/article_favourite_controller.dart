import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ArticleFavouriteController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final RxSet<int> _ignoredArticleIds = <int>{}.obs;

  /// Thêm bài viết yêu thích cho user hiện tại
  Future<void> addToFavourite(int articleId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return;
    }

    final userId = user.id;

    try {
      await _supabase.from('favourite_article').insert({
        'article_id': articleId,
        'user_id': userId,
      });
    } catch (e) {
      return;
    }
  }

  /// Kiểm tra đã yêu thích chưa
  Future<bool> isFavourited(int articleId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final result = await _supabase
        .from('favourite_article')
        .select()
        .eq('article_id', articleId)
        .eq('user_id', user.id)
        .maybeSingle();

    return result != null;
  }
  /// xóa yêu thich
  Future<void> removeFromFavourite(int articleId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase
          .from('favourite_article')
          .delete()
          .eq('article_id', articleId)
          .eq('user_id', user.id);
    } catch (e) {
      return;
    }
  }

  void ignoreArticle(int articleId) {
    _ignoredArticleIds.add(articleId);
  }

  bool isIgnored(int articleId) {
    return _ignoredArticleIds.contains(articleId);
  }

  List<int> get ignoredIds => _ignoredArticleIds.toList();
}
