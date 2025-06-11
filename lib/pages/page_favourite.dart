import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/pages/page_read.dart';
import '../controllers/favourite_controller.dart';
import '../types/favourite_item.dart';
import '../components/card_list/feed_list.dart';
import '../types/feed_item_local.dart';
import '../controllers/article_favourite_controller.dart';
import 'dart:async';

class PageFavourite extends StatefulWidget {
  const PageFavourite({super.key});

  @override
  State<PageFavourite> createState() => _PageFavouriteState();
}

class _PageFavouriteState extends State<PageFavourite> {
  late final FavouriteController controller;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    controller = FavouriteController();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    if (!Get.isRegistered<ArticleFavouriteController>()) {
      Get.put(ArticleFavouriteController());
    }
    // Load favourites when page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadFavourites();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      controller.loadFavourites();
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      controller.search(_searchController.text);
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sắp xếp',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    ListTile(
                      title: const Text('Ngày đăng mới nhất'),
                      leading: const Icon(Icons.access_time),
                      selected: controller.sortBy.value == 'pub_date' && !controller.sortAscending.value,
                      onTap: () {
                        controller.sort('pub_date', ascending: false);
                        Get.back();
                      },
                    ),
                    ListTile(
                      title: const Text('Ngày đăng cũ nhất'),
                      leading: const Icon(Icons.access_time),
                      selected: controller.sortBy.value == 'pub_date' && controller.sortAscending.value,
                      onTap: () {
                        controller.sort('pub_date', ascending: true);
                        Get.back();
                      },
                    ),
                    ListTile(
                      title: const Text('Tiêu đề A-Z'),
                      leading: const Icon(Icons.sort_by_alpha),
                      selected: controller.sortBy.value == 'title' && controller.sortAscending.value,
                      onTap: () {
                        controller.sort('title', ascending: true);
                        Get.back();
                      },
                    ),
                    ListTile(
                      title: const Text('Tiêu đề Z-A'),
                      leading: const Icon(Icons.sort_by_alpha),
                      selected: controller.sortBy.value == 'title' && !controller.sortAscending.value,
                      onTap: () {
                        controller.sort('title', ascending: false);
                        Get.back();
                      },
                    ),
                    ListTile(
                      title: const Text('Đặt lại'),
                      leading: const Icon(Icons.refresh),
                      selected: controller.sortBy.value == 'title' && !controller.sortAscending.value,
                      onTap: () {
                        controller.resetFilters();
                        Get.back();
                      },
                    ),
                  ],
                ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => controller.loadFavourites(refresh: true),
            child: Obx(() {
              if (controller.isLoading.value && controller.favourites.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return _buildBody(context);
            }),
          ),
          if (controller.isLoadingMore.value && controller.favourites.isNotEmpty)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    ));
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
      title: const Text('Bài viết yêu thích', style: TextStyle(fontWeight: FontWeight.w600)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: TextField(
            textAlign: TextAlign.justify,
            controller: _searchController,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm bài viết',
              hintStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade600,
                size: 20,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        controller.search('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
            ),
            onChanged: (value) {
              controller.search(value);
            },
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterBottomSheet,
        ),
        if (controller.favourites.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: controller.enableSelectMode,
            tooltip: 'Chọn nhiều',
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

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
        keywords: const [],
      );
    }).toList();

    return Stack(
      children: [
        FeedList(
          items: feedItems,
          emptyCategory: 'yêu thích',
          isSelectMode: controller.isSelectMode.value,
          isSelected: (fi) => controller.isSelected(
              controller.favourites.firstWhere((f) => f.id == fi.articleId)),
          onSelect: (fi) {
            final fav = controller.favourites.firstWhereOrNull((f) => f.id == fi.articleId);
            if (fav != null) {
              controller.toggleItemSelection(fav);
            }
          },
          onItemTap: (fi) => _navigateToDetail(fi),
        ),
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

  void _navigateToDetail(FeedItem item) {
    Get.to(() => PageRead(url: item.link, isVn: item.isVn, articleId: item.articleId));
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
          Obx(() => controller.isLoading.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton(
                onPressed: () {
                  Get.back();
                  _deleteSelectedItems();
                },
                child: const Text(
                  'Xóa',
                  style: TextStyle(color: Colors.red),
                ),
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