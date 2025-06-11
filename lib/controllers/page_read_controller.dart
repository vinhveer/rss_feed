import 'package:get/get.dart';
import 'package:rss_feed/repositories/extract_content_repository.dart';
import '../types/article.dart';
import '../controllers/translate_controller.dart';
import '../repositories/recommend_repository.dart';
import '../types/feed_item_local.dart';

class PageReadController extends GetxController {
  final String url;
  final bool isVn;
  final int articleId;

  PageReadController({
    required this.url,
    required this.isVn,
    required this.articleId,
  });

  final _repository = ArticleContentRepository();
  final _recommendRepository = RecommendRepository();
  final _translateService = TranslateController();

  // Observable states
  final _article = Rxn<ArticleData>();
  final _originalArticle = Rxn<ArticleData>();
  final _loading = true.obs;
  final _isTranslating = false.obs;
  final _isTranslated = false.obs;
  final _isContentLoaded = false.obs;
  final _showFontSizeSlider = false.obs;
  final _fontSize = 18.0.obs;

  // Bài viết liên quan
  final RxList<FeedItem> relatedArticles = <FeedItem>[].obs;
  final RxBool isLoadingRelated = false.obs;

  // Getters
  ArticleData? get article => _article.value;
  ArticleData? get originalArticle => _originalArticle.value;
  bool get loading => _loading.value;
  bool get isTranslating => _isTranslating.value;
  bool get isTranslated => _isTranslated.value;
  bool get isContentLoaded => _isContentLoaded.value;
  bool get showFontSizeSlider => _showFontSizeSlider.value;
  double get fontSize => _fontSize.value;

  static const double minFontSize = 12;
  static const double maxFontSize = 28;

  @override
  void onInit() {
    super.onInit();
    loadArticle();
  }

  Future<void> loadArticle() async {
    if (_isContentLoaded.value) return;

    _loading.value = true;

    try {
      final result = await _repository.fetchArticleContent(url);

      if (result != null) {
        final articleData = ArticleData.fromJson(result);
        _originalArticle.value = articleData;
        _article.value = articleData;
        _isContentLoaded.value = true;
        // Fetch related articles sau khi load xong bài chính
        fetchRelatedArticles();
      } else {
        _article.value = null;
      }
    } catch (e) {
      _article.value = null;
      Get.snackbar(
        'Lỗi',
        'Không thể tải bài viết: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _loading.value = false;
    }
  }

  Future<void> fetchRelatedArticles() async {
    if (articleId == 0) return;
    isLoadingRelated.value = true;
    try {
      // Lấy bài viết liên quan trực tiếp
      final articles = await _recommendRepository.getRelatedArticlesForArticle(articleId);
      if (articles.isEmpty) {
        relatedArticles.clear();
        return;
      }
      // Convert sang FeedItem
      relatedArticles.assignAll(
        articles.map((a) => FeedItem(
          articleId: a.articleId,
          title: a.title,
          source: a.description,
          timeAgo: a.pubDate.toString(),
          imageUrl: a.imageUrl,
          category: '', // Không có category trong API response
          link: a.link,
          isVn: true, // Mặc định là true vì không có thông tin trong API
          keywords: const [], // Không có keywords trong API response
        )).where((a) => a.articleId != articleId).toList(),
      );
    } catch (e) {
      relatedArticles.clear();
    } finally {
      isLoadingRelated.value = false;
    }
  }

  Future<void> toggleTranslation() async {
    if (_article.value == null || _isTranslating.value) return;

    if (_isTranslated.value) {
      _article.value = _originalArticle.value;
      _isTranslated.value = false;
      return;
    }

    _isTranslating.value = true;

    final fromLang = isVn ? 'vi' : 'en';
    final toLang = isVn ? 'en' : 'vi';

    try {
      final currentArticle = _article.value!;
      final translatedTitle = await _translateService.translate(
          currentArticle.title,
          fromLang,
          toLang
      );
      final translatedText = await _translateService.translate(
          currentArticle.text,
          fromLang,
          toLang
      );

      _article.value = ArticleData(
        title: translatedTitle,
        text: translatedText,
        images: currentArticle.images,
        pubDate: currentArticle.pubDate,
        author: currentArticle.author,
      );
      _isTranslated.value = true;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Lỗi dịch: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isTranslating.value = false;
    }
  }

  void toggleFontSizeSlider() {
    _showFontSizeSlider.value = !_showFontSizeSlider.value;
  }

  void updateFontSize(double size) {
    _fontSize.value = size;
  }

  void retryLoadArticle() {
    _isContentLoaded.value = false;
    loadArticle();
  }
}
