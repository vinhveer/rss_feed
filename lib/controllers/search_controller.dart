import 'package:get/get.dart';
import '../types/feed_item_local.dart';
import '../repositories/search_repository.dart';

class SearchController extends GetxController {
  final SearchRepository _repository = SearchRepository();
  
  final RxList<FeedItem> searchResults = <FeedItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreResults = true.obs;
  final RxString searchQuery = ''.obs;
  final RxString errorMessage = ''.obs;
  int _currentPage = 0;

  Future<void> searchArticles(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      searchQuery.value = query;
      _currentPage = 0;
      hasMoreResults.value = true;
      
      final results = await _repository.searchArticles(query);
      searchResults.value = results;
      
      hasMoreResults.value = await _repository.hasMoreResults(query, _currentPage);
    } catch (e) {
      errorMessage.value = 'Có lỗi xảy ra khi tìm kiếm. Vui lòng thử lại.';
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreResults() async {
    if (isLoadingMore.value || !hasMoreResults.value || searchQuery.value.isEmpty) {
      return;
    }

    try {
      isLoadingMore.value = true;
      _currentPage++;
      
      final moreResults = await _repository.searchArticles(
        searchQuery.value,
        page: _currentPage,
      );
      
      searchResults.addAll(moreResults);
      hasMoreResults.value = await _repository.hasMoreResults(searchQuery.value, _currentPage);
    } catch (e) {
      errorMessage.value = 'Có lỗi xảy ra khi tải thêm kết quả. Vui lòng thử lại.';
    } finally {
      isLoadingMore.value = false;
    }
  }

  void clearSearch() {
    searchResults.clear();
    searchQuery.value = '';
    errorMessage.value = '';
    _currentPage = 0;
    hasMoreResults.value = true;
  }
} 