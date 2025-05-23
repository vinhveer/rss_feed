import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/favourite_controller.dart';
import '../models/favourite_item.dart';
import '../components/feed_list.dart';
import '../models/feed_item_local.dart';
import '../controllers/article_favourite_controller.dart';

class PageFavourite extends StatefulWidget {
  const PageFavourite({super.key});

  @override
  State<PageFavourite> createState() => _PageFavouriteState();
}

class _PageFavouriteState extends State<PageFavourite> {
  late final FavouriteController controller;

  @override
  void initState() {
    super.initState();
    controller = FavouriteController();
    // Load favourites when page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadFavourites();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: controller.loadFavourites,
        child: Obx(() {
          if (controller.isLoading.value && controller.favourites.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return _buildBody(context);
        }),
      ),
      floatingActionButton: Obx(() {
        if (controller.isSelectMode.value && controller.selectedItems.isNotEmpty) {
          return FloatingActionButton(
            onPressed: _showDeleteConfirmDialog,
            backgroundColor: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    if (controller.isSelectMode.value) {
      return AppBar(
        title: Text('Đã chọn ${controller.selectedItems.length}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: controller.cancelSelection,
        ),
        actions: [
          if (controller.selectedItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteConfirmDialog,
            ),
        ],
      );
    }

    return AppBar(
      title: const Text('Bài viết yêu thích'),
      actions: [
        if (controller.favourites.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: controller.enableSelectMode,
            tooltip: 'Chọn nhiều',
          ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: controller.loadFavourites,
          tooltip: 'Làm mới',
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.favourites.isEmpty) {
      return _buildEmptyState(context);
    }

    // Convert FavouriteItem to FeedItem
    final feedItems = controller.favourites.map((favourite) {
      return FeedItem(
        articleId: favourite.id,
        title: favourite.title,
        source: favourite.description ?? '',
        timeAgo: favourite.pubDate.toString(),
        imageUrl: favourite.imageUrl ?? '',
        category: '',
        link: favourite.link,
        isVn: true,
      );
    }).toList();

    return Stack(
      children: [
        FeedList(
          items: feedItems,
          emptyCategory: 'yêu thích',
          onItemTap: _handleItemTap,
        ),
        if (controller.isSelectMode.value)
          _buildSelectionOverlay(),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[600]
                : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có bài viết yêu thích',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm bài viết vào danh sách yêu thích\nđể xem lại sau',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[500]
                  : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withAlpha(26),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.favourites.length,
          itemBuilder: (context, index) {
            final item = controller.favourites[index];
            final isSelected = controller.isSelected(item);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => controller.toggleItemSelection(item),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (_) => controller.toggleItemSelection(item),
                        ),
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleItemTap(FeedItem item) {
    if (controller.isSelectMode.value) {
      // Tìm FavouriteItem tương ứng
      final favouriteItem = controller.favourites.firstWhereOrNull(
        (f) => f.id == item.articleId,
      );
      if (favouriteItem != null) {
        controller.toggleItemSelection(favouriteItem);
      }
    } else {
      // Xử lý tap bình thường - có thể navigate đến detail page
      _navigateToDetail(item);
    }
  }

  void _navigateToDetail(FeedItem item) {
    // TODO: Navigate to article detail page
    // Get.toNamed('/article-detail', arguments: item);
    print('Navigate to detail: ${item.title}');
  }

  void _showDeleteConfirmDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          controller.selectedItems.length == 1
              ? 'Bạn có chắc chắn muốn xóa bài viết này khỏi danh sách yêu thích?'
              : 'Bạn có chắc chắn muốn xóa ${controller.selectedItems.length} bài viết khỏi danh sách yêu thích?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _deleteSelectedItems();
            },
            child: const Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteSelectedItems() async {
    final selectedCount = controller.selectedItems.length;
    final deletedItems = List<FavouriteItem>.from(controller.selectedItems);
    
    try {
      await controller.deleteSelected();
      
      // Show success snackbar with undo option
      Get.snackbar(
        'Đã xóa',
        'Đã xóa $selectedCount bài viết khỏi danh sách yêu thích',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () {
            _undoDelete(deletedItems);
            Get.closeCurrentSnackbar();
          },
          child: const Text(
            'HOÀN TÁC',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể xóa bài viết: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _undoDelete(List<FavouriteItem> deletedItems) async {
    try {
      for (final item in deletedItems) {
        await controller.undoDelete(item);
      }
      
      Get.snackbar(
        'Đã khôi phục',
        'Đã khôi phục ${deletedItems.length} bài viết',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể khôi phục bài viết: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}