import 'dart:async';
import 'package:get/get.dart';
import '../repositories/explore_repository.dart';
import '../row_row_row/tables/newspaper.row.dart';
import '../row_row_row/tables/topic.row.dart';

class FindController extends GetxController {
  final ExploreRepository _repository = ExploreRepository();
  
  // Observable states
  final RxList<TopicRow> topics = <TopicRow>[].obs;
  final RxList<NewspaperRow> newspapers = <NewspaperRow>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  // Debounce timer for search
  Timer? _debounce;

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchQuery.value = query;
      if (query.isNotEmpty) {
        search(query);
      } else {
        clearResults();
      }
    });
  }

  Future<void> search(String query) async {
    if (query.isEmpty) return;
    
    isLoading.value = true;
    try {
      // Search topics and newspapers in parallel
      final results = await Future.wait([
        _repository.searchTopics(query),
        _repository.searchNewspapers(query),
      ]);

      topics.assignAll(results[0] as List<TopicRow>);
      newspapers.assignAll(results[1] as List<NewspaperRow>);
    } catch (e) {
      print('Error searching: $e');
      // You might want to show an error message to the user
    } finally {
      isLoading.value = false;
    }
  }

  void clearResults() {
    topics.clear();
    newspapers.clear();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
} 