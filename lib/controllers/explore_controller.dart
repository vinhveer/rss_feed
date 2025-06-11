import 'package:get/get.dart';
import '../repositories/explore_repository.dart';
import '../row_row_row/tables/newspaper.row.dart';
import '../row_row_row/tables/topic.row.dart';

class ExploreController extends GetxController {
  final ExploreRepository _repository = ExploreRepository();
  
  // Observable states
  final RxList<TopicRow> topics = <TopicRow>[].obs;
  final RxList<NewspaperRow> newspapers = <NewspaperRow>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      // Load featured topics and newspapers in parallel
      final results = await Future.wait([
        _repository.getFeaturedTopics(),
        _repository.getFeaturedNewspapers(),
      ]);

      topics.assignAll(results[0] as List<TopicRow>);
      newspapers.assignAll(results[1] as List<NewspaperRow>);
    } catch (e) {
      print('Error loading explore data: $e');
      // You might want to show an error message to the user
    } finally {
      isLoading.value = false;
    }
  }
} 