  import 'package:get/get.dart';
  import 'package:flutter/material.dart';
  import 'package:rss_feed/types/favourite_item.dart';
  import 'package:rss_feed/repositories/favourite_repository.dart';

  class FavouriteController extends GetxController {
    final FavouriteRepository _repository;

    final RxList<FavouriteItem> favourites = <FavouriteItem>[].obs;
    final RxList<FavouriteItem> selectedItems = <FavouriteItem>[].obs;
    final RxBool isLoading = false.obs;
    final RxBool isLoadingMore = false.obs;
    final RxBool isSelectMode = false.obs;
    final RxBool hasMore = true.obs;
    final RxString searchQuery = ''.obs;
    final RxString sortBy = 'pub_date'.obs;
    final RxBool sortAscending = false.obs;

    static const int _pageSize = 20;
    int _currentOffset = 0;

    FavouriteController({
      FavouriteRepository? repository,
    }) : _repository = repository ?? FavouriteRepository();

    @override
    void onInit() {
      super.onInit();
      // Auto load favourites when controller is initialized
      loadFavourites();
    }

    /// Load favorites with pagination and infinite scroll support
    Future<void> loadFavourites({bool refresh = false}) async {
      // Prevent multiple simultaneous requests
      if (!refresh && (isLoading.value || isLoadingMore.value)) return;
      
      if (refresh) {
        _currentOffset = 0;
        hasMore.value = true;
        isLoading.value = true;
      } else {
        if (!hasMore.value) return;
        isLoadingMore.value = true;
      }

      try {
        final response = await _repository.loadFavourites(
          offset: _currentOffset,
          limit: _pageSize,
          searchQuery: searchQuery.value.trim(),
          sortBy: sortBy.value,
          sortAscending: sortAscending.value,
        );

        if (refresh) {
          favourites.clear();
        }

        // Check if we have more data
        if (response.length < _pageSize) {
          hasMore.value = false;
        }

        favourites.addAll(response);
        _currentOffset += response.length;
      } catch (e) {
        print('Error loading favourites: $e');
        // Show error message to user
        Get.snackbar(
          'Lỗi',
          'Không thể tải danh sách yêu thích: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
        rethrow;
      } finally {
        isLoading.value = false;
        isLoadingMore.value = false;
      }
    }

    /// Search favorites with debouncing
    Future<void> search(String query) async {
      searchQuery.value = query.trim();
      await loadFavourites(refresh: true);
    }

    /// Advanced search with multiple filters
    Future<void> searchWithFilters({
      String? query,
      String? sortField,
      bool? ascending,
    }) async {
      if (query != null) searchQuery.value = query.trim();
      if (sortField != null) sortBy.value = sortField;
      if (ascending != null) sortAscending.value = ascending;
      
      await loadFavourites(refresh: true);
    }

    /// Sort favorites
    Future<void> sort(String field, {bool ascending = false}) async {
      sortBy.value = field;
      sortAscending.value = ascending;
      await loadFavourites(refresh: true);
    }

    /// Reset all filters and search
    Future<void> resetFilters() async {
      searchQuery.value = '';
      sortBy.value = 'pub_date';
      sortAscending.value = false;
      await loadFavourites(refresh: true);
    }

    /// Load a specific favorite by article ID
    Future<FavouriteItem?> loadFavouriteByArticleId(int articleId) async {
      try {
        final response = await _repository.loadFavouriteByArticleId(articleId);
        return response;
      } catch (e) {
        print('Error loading favourite by article ID: $e');
        Get.snackbar(
          'Lỗi',
          'Không thể tải bài viết yêu thích',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }
    }

    /// Delete a single favorite item
    Future<void> deleteFavouriteItem(FavouriteItem item) async {
      try {
        await _repository.deleteFavouriteItem(item.id);
        favourites.removeWhere((f) => f.id == item.id);
        
        Get.snackbar(
          'Đã xóa',
          'Đã xóa bài viết khỏi danh sách yêu thích',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
          duration: const Duration(seconds: 3),
          mainButton: TextButton(
            onPressed: () {
              undoDelete(item);
              Get.closeCurrentSnackbar();
            },
            child: Text(
              'HOÀN TÁC',
              style: TextStyle(
                color: Get.theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } catch (e) {
        Get.snackbar(
          'Lỗi',
          'Không thể xóa bài viết: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        rethrow;
      }
    }

    /// Undo a delete operation
    Future<void> undoDelete(FavouriteItem item) async {
      try {
        await _repository.createFavouriteItem(item.id);
        // Reload the item to get the full data
        final insertedItem = await loadFavouriteByArticleId(item.id);
        if (insertedItem != null && !favourites.any((f) => f.id == item.id)) {
          favourites.insert(0, insertedItem);
          Get.snackbar(
            'Đã khôi phục',
            'Đã khôi phục bài viết',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.secondary,
            colorText: Get.theme.colorScheme.onSecondary,
          );
        }
      } catch (e) {
        Get.snackbar(
          'Lỗi',
          'Không thể khôi phục bài viết: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
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

    /// Select all items
    void selectAllItems() {
      selectedItems.clear();
      selectedItems.addAll(favourites);
    }

    /// Deselect all items
    void deselectAllItems() {
      selectedItems.clear();
    }

    /// Toggle select all/none
    void toggleSelectAll() {
      if (selectedItems.length == favourites.length) {
        deselectAllItems();
      } else {
        selectAllItems();
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

    /// Delete selected items with confirmation
    Future<void> deleteSelected() async {
      if (selectedItems.isEmpty) return;
      
      final itemsToDelete = List<FavouriteItem>.from(selectedItems);
      final count = itemsToDelete.length;
      
      try {
        final ids = itemsToDelete.map((e) => e.id).toList();
        await _repository.deleteMultipleFavourites(ids);
        
        // Remove items from the list
        favourites.removeWhere((f) => ids.contains(f.id));
        
        // Exit selection mode
        cancelSelection();
        
        // Show success message with undo option
        Get.snackbar(
          'Đã xóa',
          'Đã xóa $count bài viết khỏi danh sách yêu thích',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
          duration: const Duration(seconds: 4),
          mainButton: TextButton(
            onPressed: () {
              _undoMultipleDelete(itemsToDelete);
              Get.closeCurrentSnackbar();
            },
            child: Text(
              'HOÀN TÁC',
              style: TextStyle(
                color: Get.theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } catch (e) {
        Get.snackbar(
          'Lỗi',
          'Không thể xóa bài viết: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        rethrow;
      }
    }

    /// Undo multiple delete operation
    Future<void> _undoMultipleDelete(List<FavouriteItem> deletedItems) async {
      try {
        for (final item in deletedItems) {
          await _repository.createFavouriteItem(item.id);
          final insertedItem = await loadFavouriteByArticleId(item.id);
          if (insertedItem != null && !favourites.any((f) => f.id == item.id)) {
            favourites.insert(0, insertedItem);
          }
        }
        
        Get.snackbar(
          'Đã khôi phục',
          'Đã khôi phục ${deletedItems.length} bài viết',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.secondary,
          colorText: Get.theme.colorScheme.onSecondary,
        );
      } catch (e) {
        Get.snackbar(
          'Lỗi',
          'Không thể khôi phục bài viết: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    }

    /// Check if an item is selected
    bool isSelected(FavouriteItem item) {
      return selectedItems.any((i) => i.id == item.id);
    }

    /// Get current filter status text
    String get filterStatusText {
      if (searchQuery.value.isNotEmpty) {
        return 'Tìm kiếm: "${searchQuery.value}"';
      }
      
      String sortText = '';
      switch (sortBy.value) {
        case 'pub_date':
          sortText = sortAscending.value ? 'Cũ nhất' : 'Mới nhất';
          break;
        case 'title':
          sortText = sortAscending.value ? 'A-Z' : 'Z-A';
          break;
        default:
          sortText = 'Mặc định';
      }
      
      return 'Sắp xếp: $sortText';
    }

    /// Check if any filters are active
    bool get hasActiveFilters {
      return searchQuery.value.isNotEmpty || 
            sortBy.value != 'pub_date' || 
            sortAscending.value != false;
    }

    /// Get selection status text
    String get selectionStatusText {
      if (selectedItems.isEmpty) return 'Chọn bài viết';
      return 'Đã chọn ${selectedItems.length}/${favourites.length}';
    }
  }