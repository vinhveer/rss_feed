import 'package:get/get.dart';
import '../repositories/recommend_repository.dart';
import '../repositories/keyword_repository.dart';
import '../services/local_storage_service.dart';
import '../types/recommend_keyword.dart';
import '../app.dart';

class ChooseKeywordController extends GetxController {
  final RecommendRepository _repository = RecommendRepository();
  final KeywordRepository _keywordRepository = KeywordRepository();
  final LocalStorageService _storage = LocalStorageService();
 
  static const String _storageKey = 'selected_keywords';
  static const int _minKeywords = 5;
  
  // Observable states
  final RxList<RecommendKeyword> selectedKeywords = <RecommendKeyword>[].obs;
  final RxList<RecommendKeyword> hotKeywords = <RecommendKeyword>[].obs;
  final RxBool isLoading = false.obs;
  
  // Map để lưu từ khóa liên quan cho mỗi hot keyword
  final RxMap<int, List<RecommendKeyword>> relatedKeywordsMap = <int, List<RecommendKeyword>>{}.obs;
  
  // Set để track những hot keyword đã được expand
  final RxSet<int> expandedKeywords = <int>{}.obs;
  
  // Set để track những keyword đã load related keywords
  final RxSet<int> loadedRelatedKeywords = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadHotKeywords();
    loadSavedKeywords();
  }
  
  // Getter để tạo danh sách hiển thị có thứ tự
  List<RecommendKeyword> get displayKeywords {
    List<RecommendKeyword> result = [];
    Set<String> addedKeywords = {}; // Set để track các keyword đã thêm
    
    for (RecommendKeyword hotKeyword in hotKeywords) {
      // Tạo unique key từ keywordId và keywordName
      String uniqueKey = '${hotKeyword.keywordId}_${hotKeyword.keywordName}';
      
      // Thêm hot keyword nếu chưa có trong danh sách
      if (!addedKeywords.contains(uniqueKey)) {
        result.add(hotKeyword);
        addedKeywords.add(uniqueKey);
      }
      
      // Nếu hot keyword này đã được expand, thêm related keywords
      if (expandedKeywords.contains(hotKeyword.keywordId)) {
        final relatedList = relatedKeywordsMap[hotKeyword.keywordId] ?? [];
        for (var relatedKeyword in relatedList) {
          // Tạo unique key cho related keyword
          String relatedUniqueKey = '${relatedKeyword.keywordId}_${relatedKeyword.keywordName}';
          
          // Chỉ thêm related keyword nếu chưa có trong danh sách
          if (!addedKeywords.contains(relatedUniqueKey)) {
            result.add(relatedKeyword);
            addedKeywords.add(relatedUniqueKey);
          }
        }
      }
    }
    
    return result;
  }
  
  // Getter để lấy danh sách hot keywords hiện tại
  List<RecommendKeyword> get currentHotKeywords => hotKeywords.toList();
  
  // Getter để lấy danh sách related keywords hiện tại (cho UI cũ nếu cần)
  List<RecommendKeyword> get currentRelatedKeywords {
    List<RecommendKeyword> allRelated = [];
    for (var list in relatedKeywordsMap.values) {
      allRelated.addAll(list);
    }
    return allRelated;
  }

  Future<void> loadHotKeywords() async {
    try {
      isLoading.value = true;
      final keywords = await _repository.getHotKeywords();
      hotKeywords.value = keywords;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tải từ khóa hot: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadRelatedKeywords(String keywordName, int keywordId) async {
    try {
      isLoading.value = true;
      final response = await _repository.getRelatedArticlesByKeywordName(
        keywordName: keywordName,
        limit: 10,
      );
     
      // Parse keywords with null safety
      final keywordsList = response['keywords'] as List?;
      if (keywordsList == null) {
        return;
      }
     
      final newKeywords = keywordsList
          .map((keyword) => RecommendKeyword.fromJson(keyword))
          .toList();
     
      // Lưu related keywords vào map với key là keywordId
      relatedKeywordsMap[keywordId] = newKeywords;
      
      // Đánh dấu là đã load
      loadedRelatedKeywords.add(keywordId);
      
      // Tự động expand khi load xong
      expandedKeywords.add(keywordId);
      
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tải từ khóa liên quan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  void toggleKeywordExpansion(int keywordId) {
    if (expandedKeywords.contains(keywordId)) {
      expandedKeywords.remove(keywordId);
    } else {
      expandedKeywords.add(keywordId);
    }
  }
  
  bool isKeywordExpanded(int keywordId) {
    return expandedKeywords.contains(keywordId);
  }
  
  bool isHotKeyword(RecommendKeyword keyword) {
    return hotKeywords.any((k) => k.keywordId == keyword.keywordId);
  }
  
  bool isRelatedKeyword(RecommendKeyword keyword) {
    return relatedKeywordsMap.values.any((list) => 
      list.any((k) => k.keywordId == keyword.keywordId));
  }

  void toggleKeyword(RecommendKeyword keyword) {
    if (selectedKeywords.contains(keyword)) {
      selectedKeywords.remove(keyword);
    } else {
      selectedKeywords.add(keyword);
    }
  }

  Future<void> loadSavedKeywords() async {
    try {
      final savedKeywords = _storage.get<List<dynamic>>(_storageKey);
      if (savedKeywords != null) {
        selectedKeywords.value = savedKeywords
            .map((k) => RecommendKeyword.fromJson(k))
            .toList();
      }
    } catch (e) {
      print('Error loading saved keywords: $e');
    }
  }

  Future<void> saveKeywords() async {
    try {
      isLoading.value = true;
      
      // Lưu vào local storage
      await _storage.set(
        _storageKey,
        selectedKeywords.map((k) => k.toJson()).toList(),
      );

      // Lưu từng keyword vào KeywordRepository
      for (var keyword in selectedKeywords) {
        await _keywordRepository.saveKeywordByName(keyword.keywordName);
      }

      // Đóng trang hiện tại và khởi tạo lại trang chủ
      Get.offAll(() => App(), transition: Transition.fade);
    } catch (e) {
      print('Error saving keywords: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể lưu từ khóa: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool get canProceed => selectedKeywords.length >= _minKeywords;
}