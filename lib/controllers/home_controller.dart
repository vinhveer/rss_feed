import 'package:get/get.dart';
import '../repositories/recommend_repository.dart';
import '../repositories/keyword_repository.dart';
import '../types/recommend_article.dart';
import '../types/recommend_keyword.dart';

class HomeController extends GetxController {
  final RecommendRepository _repository = RecommendRepository();
  final KeywordRepository _keywordRepository = KeywordRepository();

  // Observable states
  final RxList<RecommendArticle> articles = <RecommendArticle>[].obs;
  final RxList<RecommendKeyword> keywords = <RecommendKeyword>[].obs;
  final RxString selectedCategory = 'Đề xuất cho bạn'.obs;
  
  // Loading states
  final RxBool isLoadingArticles = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isLoadingKeywords = false.obs;

  static const int _pageSize = 10;
  int _currentPage = 1;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    // Load keywords first
    await loadKeywords();
    // Then load articles
    loadArticles();
  }

  Future<void> loadArticles({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      articles.clear();
    }

    if (isLoadingArticles.value || isLoadingMore.value) return;

    if (refresh) {
      isLoadingArticles.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      List<RecommendArticle> newArticles = [];
      
      switch (selectedCategory.value) {
        case 'Đề xuất cho bạn':
          if (keywords.isNotEmpty) {
            final result = await _repository.getArticlesByKeywords(
              keywords: keywords.take(3).map((k) => k.keywordName).toList(),
              page: _currentPage,
              pageSize: _pageSize,
            );
            newArticles = result['articles'];
          }
          break;
          
        case 'Nổi bật':
          final result = await _repository.getHotArticles(
            page: _currentPage,
            pageSize: _pageSize,
          );
          newArticles = result['articles'];
          break;
          
        default:
          // Nếu là keyword
          final result = await _repository.getArticlesByKeywords(
            keywords: [selectedCategory.value],
            page: _currentPage,
            pageSize: _pageSize,
          );
          newArticles = result['articles'];
          break;
      }
      
      if (refresh) {
        articles.assignAll(newArticles);
      } else {
        articles.addAll(newArticles);
      }
      
      _currentPage++;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tải bài viết: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingArticles.value = false;
      isLoadingMore.value = false;
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    loadArticles(refresh: true);
  }

  Future<void> loadKeywords() async {
    isLoadingKeywords.value = true;
    try {
      // First try to get keywords from local storage
      final storedKeywords = await _keywordRepository.getKeywordsFromStorage();
      
      if (storedKeywords.isNotEmpty) {
        // Convert stored keywords to RecommendKeyword objects
        final convertedKeywords = storedKeywords
            .map((k) => RecommendKeyword(
                  keywordId: k['keyword']['keyword_id'],
                  keywordName: k['keyword']['keyword_name'],
                  articleCount: 0, // We don't have article count in stored keywords
                ))
            .toList();
        keywords.assignAll(convertedKeywords);
      } else {
        // If no stored keywords, fetch hot keywords
        final fetchedKeywords = await _repository.getHotKeywords();
        keywords.assignAll(fetchedKeywords);
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tải keywords: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingKeywords.value = false;
    }
  }
}