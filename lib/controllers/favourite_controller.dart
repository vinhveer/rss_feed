import 'package:get/get.dart';
import 'package:rss_feed/models/favourite_item.dart';
import 'package:rss_feed/repository/favourite_repository.dart';

class FavouriteController extends GetxController {
  final FavouriteRepository _repository;

  final RxList<FavouriteItem> favourites = <FavouriteItem>[].obs;
  final RxList<FavouriteItem> selectedItems = <FavouriteItem>[].obs;
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
  Future<FavouriteItem?> loadFavouriteByArticleId(int articleId) async {
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
  Future<void> deleteFavouriteItem(FavouriteItem item) async {
    try {
      await _repository.deleteFavouriteItem(item.id);
      favourites.removeWhere((f) => f.id == item.id);
    } catch (e) {
      rethrow;
    }
  }

  /// Undo a delete operation
  Future<void> undoDelete(FavouriteItem item) async {
    try {
      await _repository.createFavouriteItem(item.id);
      // Reload the item to get the full data (if needed)
      final insertedItem = await loadFavouriteByArticleId(item.id);
      if (insertedItem != null && !favourites.any((f) => f.id == item.id)) {
        favourites.insert(0, insertedItem);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle selection state for an item
  void toggleItemSelection(FavouriteItem item) {
    final index = selectedItems.indexWhere((i) => i.id == item.id);
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
      final ids = selectedItems.map((e) => e.id).toList();
      await _repository.deleteMultipleFavourites(ids);
      favourites.removeWhere((f) => ids.contains(f.id));
      cancelSelection();
    } catch (e) {
      rethrow;
    }
  }

  /// Check if an item is selected
  bool isSelected(FavouriteItem item) {
    return selectedItems.any((i) => i.id == item.id);
  }
}