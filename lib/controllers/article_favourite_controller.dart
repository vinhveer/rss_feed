import 'package:get/get.dart';
import 'package:rss_feed/repository/article_favourite_repository.dart';

class ArticleFavouriteController extends GetxController {
  final ArticleFavouriteRepository _repository = ArticleFavouriteRepository();

  final RxSet<int> _ignoredArticleIds = <int>{}.obs;

  /// Thêm bài viết yêu thích cho user hiện tại
  Future<void> addToFavourite(int articleId) async {
    try {
      await _repository.addFavourite(articleId);
      // Có thể emit success event hoặc update UI state
    } catch (e) {
      // Handle error - show snackbar, dialog, etc.
      Get.snackbar('Error', 'Failed to add to favourite');
      rethrow;
    }
  }

  /// Kiểm tra đã yêu thích chưa
  Future<bool> isFavourited(int articleId) async {
    try {
      return await _repository.checkFavouriteExists(articleId);
    } catch (e) {
      // Handle error
      return false;
    }
  }

  /// Xóa yêu thích
  Future<void> removeFromFavourite(int articleId) async {
    try {
      await _repository.removeFavourite(articleId);
      // Có thể emit success event hoặc update UI state
    } catch (e) {
      // Handle error - show snackbar, dialog, etc.
      Get.snackbar('Error', 'Failed to remove from favourite');
      rethrow;
    }
  }

  /// Thêm bài viết vào danh sách bỏ qua
  void ignoreArticle(int articleId) {
    _ignoredArticleIds.add(articleId);
  }

  /// Kiểm tra bài viết có bị bỏ qua không
  bool isIgnored(int articleId) {
    return _ignoredArticleIds.contains(articleId);
  }

  /// Lấy danh sách ID các bài viết bị bỏ qua
  List<int> get ignoredIds => _ignoredArticleIds.toList();

  /// Xóa bài viết khỏi danh sách bỏ qua
  void unignoreArticle(int articleId) {
    _ignoredArticleIds.remove(articleId);
  }

  /// Xóa tất cả bài viết bỏ qua
  void clearIgnoredArticles() {
    _ignoredArticleIds.clear();
  }
}