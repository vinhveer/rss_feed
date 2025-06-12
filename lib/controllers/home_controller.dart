import 'package:get/get.dart';
import '../repositories/recommend_repository.dart';
import '../repositories/keyword_repository.dart';
import '../types/recommend_article.dart';
import '../types/recommend_keyword.dart';
import '../controllers/app_controller.dart';

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
  final RxBool hasInitialized = false.obs;

  static const int _pageSize = 10;
  int _currentPage = 1;

  @override
  void onInit() {
    super.onInit();
    checkKeywordsAndInitialize();
  }

  Future<void> checkKeywordsAndInitialize() async {
    isLoadingKeywords.value = true;
    try {
      // Kiểm tra keywords trong local storage
      final storedKeywords = await _keywordRepository.getKeywordsFromStorage();
      
      if (storedKeywords.isEmpty) {
        // Nếu chưa có keywords, chuyển đến trang chọn chủ đề
        Get.find<AppController>().goToPageChooseTopic();
        return;
      }

      // Nếu đã có keywords, khởi tạo data
      await initializeData();
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể kiểm tra keywords: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingKeywords.value = false;
    }
  }

  Future<void> initializeData() async {
    // Convert stored keywords to RecommendKeyword objects
    final storedKeywords = await _keywordRepository.getKeywordsFromStorage();
    final convertedKeywords = storedKeywords
        .map((k) => RecommendKeyword(
              keywordId: k['keyword']['keyword_id'],
              keywordName: k['keyword']['keyword_name'],
              articleCount: 0,
            ))
        .toList();
    keywords.assignAll(convertedKeywords);

    // Load articles
    await loadArticles();
    hasInitialized.value = true;
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
}