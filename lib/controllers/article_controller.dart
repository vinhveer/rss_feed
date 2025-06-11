import 'package:get/get.dart';
import '../types/feed_item_local.dart';
import '../repositories/article_repository.dart';
import '../row_row_row/tables/topic.row.dart';

class ArticleController extends GetxController {
  final int id; // newspaper_id hoặc topic_id
  final bool isTopic;
  final ArticleRepository _repository = ArticleRepository();

  ArticleController({required this.id, required this.isTopic});

  // Danh sách bài viết
  final RxList<FeedItem> articles = <FeedItem>[].obs;

  // Danh sách topic (khi hiển thị theo newspaper)
  final RxList<TopicRow> topics = <TopicRow>[].obs;

  // Topic được chọn (null -> Mới nhất)
  final RxnInt selectedTopicId = RxnInt();

  // Trạng thái tải dữ liệu
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;

  static const int _pageSize = 20;
  int _currentOffset = 0;

  @override
  void onInit() {
    super.onInit();

    if (!isTopic) {
      _loadTopics();
    }

    loadArticles(refresh: true);
  }

  /// Tải danh sách topic của newspaper
  Future<void> _loadTopics() async {
    try {
      final result = await _repository.getTopicsByNewspaper(id);
      topics.assignAll(result);
    } catch (e) {
      // ignore lỗi để không chặn luồng chính
      print('Error load topics: $e');
    }
  }

  /// Thay đổi topic filter (chỉ áp dụng cho newspaper)
  void selectTopic(int? topicId) {
    if (selectedTopicId.value == topicId) return;
    selectedTopicId.value = topicId;
    loadArticles(refresh: true);
  }

  /// Tải bài viết (hỗ trợ pagination)
  Future<void> loadArticles({bool refresh = false}) async {
    if (refresh) {
      _currentOffset = 0;
      hasMore.value = true;
      isLoading.value = true;
      articles.clear();
    } else {
      if (!hasMore.value) return;
      if (isLoadingMore.value) return;
      isLoadingMore.value = true;
    }

    try {
      List<FeedItem> fetched = [];

      if (isTopic) {
        fetched = await _repository.getArticlesByTopic(
          topicId: id,
          offset: _currentOffset,
          limit: _pageSize,
        );
      } else {
        fetched = await _repository.getArticlesByNewspaper(
          newspaperId: id,
          topicId: selectedTopicId.value,
          offset: _currentOffset,
          limit: _pageSize,
        );
      }

      articles.addAll(fetched);

      if (fetched.length < _pageSize) {
        hasMore.value = false;
      }

      _currentOffset += fetched.length;
    } catch (e) {
      print('Error load articles: $e');
      Get.snackbar('Lỗi', 'Không thể tải bài viết: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }
} 