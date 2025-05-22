import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/controllers/favourite_controller.dart';
import 'package:rss_feed/row_row_row/tables/favourite_article.row.dart';

class PageFavourite extends StatelessWidget {
  final FavouriteController controller = Get.put(FavouriteController());

  PageFavourite({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Load favourites when the page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadFavourites();
    });

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => controller.isSelectMode.value
            ? Text('Selected: ${controller.selectedItems.length}')
            : const Text('Favorites')),
        actions: [
          Obx(() {
            if (controller.isSelectMode.value) {
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: controller.selectedItems.isEmpty
                        ? null
                        : () => _confirmDelete(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: controller.cancelSelection,
                  ),
                ],
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.select_all),
                onPressed: controller.enableSelectMode,
              );
            }
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.favourites.isEmpty) {
          return const Center(
            child: Text('No favorites yet', style: TextStyle(fontSize: 16)),
          );
        }

        return ListView.builder(
          itemCount: controller.favourites.length,
          itemBuilder: (context, index) {
            final item = controller.favourites[index];
            return _buildFavouriteItem(context, item);
          },
        );
      }),
    );
  }

  Widget _buildFavouriteItem(BuildContext context, FavouriteArticleRow item) {
    return Obx(() {
      final isSelected = controller.isSelected(item);

      return Dismissible(
        key: Key('favourite_${item.articleId}'),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => _handleDismiss(context, item),
        child: ListTile(
          leading: controller.isSelectMode.value
              ? Checkbox(
            value: isSelected,
            onChanged: (_) => controller.toggleItemSelection(item),
          )
              : const Icon(Icons.favorite, color: Colors.red),
          title: Text(item.title ?? 'No title'),
          subtitle: item.description != null
              ? Text(
            item.description!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
              : null,
          selected: isSelected,
          onTap: controller.isSelectMode.value
              ? () => controller.toggleItemSelection(item)
              : () => _navigateToArticleDetail(item),
          onLongPress: () {
            if (!controller.isSelectMode.value) {
              controller.enableSelectMode();
              controller.toggleItemSelection(item);
            }
          },
        ),
      );
    });
  }

  void _handleDismiss(BuildContext context, FavouriteArticleRow item) async {
    try {
      await controller.deleteFavouriteItem(item);

      // Show snackbar with undo option
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item removed from favorites'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () => controller.undoDelete(item),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete selected'),
        content: Text(
            'Are you sure you want to delete ${controller.selectedItems.length} selected item(s)?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteSelected();
              Navigator.of(context).pop();
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  void _navigateToArticleDetail(FavouriteArticleRow item) {
    // Navigate to article detail page
    // Get.to(() => ArticleDetailPage(articleId: item.articleId));

    // This is a placeholder - implement your navigation logic
    print('Navigate to article: ${item.articleId}');
  }
}