import 'package:get/get.dart';
import 'package:rss_feed/row_row_row/tables/favourite_article.row.dart';
import 'package:rss_feed/repository/favourite_repository.dart';

class FavouriteController extends GetxController {
  final FavouriteRepository _repository;

  final RxList<FavouriteArticleRow> favourites = <FavouriteArticleRow>[].obs;
  final RxList<FavouriteArticleRow> selectedItems = <FavouriteArticleRow>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSelectMode = false.obs;

  FavouriteController({
    FavouriteRepository? repository,
  }) : _repository = repository ?? FavouriteRepository();

  /// Load all favorites
  Future<void> loadFavourites() async {
    isLoading.value = true;
    try {
      final response = await _repository.loadFavourites();
      favourites.assignAll(response);
    } catch (e) {
      print('Error loading favourites: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Load a specific favorite by article ID
  Future<FavouriteArticleRow?> loadFavouriteByArticleId(int articleId) async {
    isLoading.value = true;
    try {
      final response = await _repository.loadFavouriteByArticleId(articleId);
      return response;
    } catch (e) {
      print('Error loading favourite by article ID: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a favorite item
  Future<void> deleteFavouriteItem(FavouriteArticleRow item) async {
    try {
      await _repository.deleteFavouriteItem(item.articleId);
      favourites.removeWhere((f) => f.articleId == item.articleId);
    } catch (e) {
      rethrow;
    }
  }

  /// Undo a delete operation
  Future<void> undoDelete(FavouriteArticleRow item) async {
    try {
      await _repository.createFavouriteItem(item.articleId);
      // Reload the item to get the full data (if needed)
      final insertedItem = await loadFavouriteByArticleId(item.articleId);
      if (insertedItem != null && !favourites.any((f) => f.articleId == item.articleId)) {
        favourites.insert(0, insertedItem);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle selection state for an item
  void toggleItemSelection(FavouriteArticleRow item) {
    final index = selectedItems.indexWhere((i) => i.articleId == item.articleId);
    if (index >= 0) {
      selectedItems.removeAt(index);
    } else {
      selectedItems.add(item);
    }
  }

  /// Enable selection mode
  void enableSelectMode() {
    isSelectMode.value = true;
    selectedItems.clear();
  }

  /// Cancel selection mode
  void cancelSelection() {
    isSelectMode.value = false;
    selectedItems.clear();
  }

  /// Delete selected items
  Future<void> deleteSelected() async {
    if (selectedItems.isEmpty) return;
    try {
      final ids = selectedItems.map((e) => e.articleId).toList();
      await _repository.deleteMultipleFavourites(ids);
      favourites.removeWhere((f) => ids.contains(f.articleId));
      cancelSelection();
    } catch (e) {
      rethrow;
    }
  }

  /// Check if an item is selected
  bool isSelected(FavouriteArticleRow item) {
    return selectedItems.any((i) => i.articleId == item.articleId);
  }
}