import 'package:flutter/material.dart';
import '../controllers/favourite_controller.dart';
import '../models/favourite_item.dart';

import '../components/category_filter_bar.dart';
import '../components/item_action_bar.dart';
import '../components/category_utils.dart';

class PageFavourite extends StatefulWidget {
  const PageFavourite({super.key});

  @override
  State<PageFavourite> createState() => _PageFavouriteState();
}

class _PageFavouriteState extends State<PageFavourite> {
  final FavouriteController _controller = FavouriteController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _controller.isSelectMode
            ? Text('Đã chọn ${_controller.selectedCount} mục', style: TextStyle(fontWeight: FontWeight.w600))
            : const Text("Danh mục yêu thích", style: TextStyle(fontWeight: FontWeight.w600)),
        actions: _buildAppBarActions(),
      ),
      body: Column(
        children: [
          // Dùng CategoryFilterBar thay vì tự build thủ công
          CategoryFilterBar(
            categories: _controller.categories,
            selectedFilter: _controller.selectedFilter,
            onFilterSelected: (category) {
              setState(() {
                _controller.setFilter(category);
              });
            },
          ),
          Expanded(child: _buildFavouritesList()),
        ],
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_controller.isSelectMode) {
      return [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _controller.selectedCount > 0
              ? () {
            setState(() {
              _controller.deleteSelected();
            });
          }
              : null,
          tooltip: 'Xóa các mục đã chọn',
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _controller.cancelSelection();
            });
          },
          tooltip: 'Hủy chọn',
        ),
      ];
    } else {
      return [
        IconButton(
          icon: const Icon(Icons.select_all),
          onPressed: _controller.favourites.isNotEmpty
              ? () {
            setState(() {
              _controller.enableSelectMode();
            });
          }
              : null,
          tooltip: 'Chọn nhiều',
        ),
        IconButton(
          icon: const Icon(Icons.sort),
          onPressed: _showSortOptions,
          tooltip: 'Sắp xếp',
        ),
      ];
    }
  }

  Widget _buildFavouritesList() {
    final filtered = _controller.filteredFavourites;
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _controller.selectedFilter == 'Tất cả'
                  ? 'Chưa có mục yêu thích nào'
                  : 'Chưa có mục yêu thích nào trong ${_controller.selectedFilter}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return _buildFavouriteCard(item);
      },
    );
  }

  Widget _buildFavouriteCard(FavouriteItem item) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = CategoryUtils.getCategoryColor(item.category, context);
    final categoryIcon = CategoryUtils.getIconForCategory(item.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _controller.isSelectMode
            ? () {
          setState(() {
            _controller.toggleItemSelection(item);
          });
        }
            : () => _viewItem(item),
        onLongPress: !_controller.isSelectMode
            ? () {
          setState(() {
            _controller.toggleItemSelection(item);
          });
        }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      child: Center(
                        child: Icon(
                          categoryIcon,
                          size: 48,
                          color: categoryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_controller.isSelectMode)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.white.withOpacity(0.7),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          item.isSelected
                              ? Icons.check
                              : Icons.circle_outlined,
                          size: 20,
                          color: item.isSelected
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: CategoryUtils.getCategoryBackgroundColor(item.category, context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: categoryColor,
                          ),
                        ),
                      ),
                      Text(
                        _formatSavedDate(item.savedDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Sử dụng ItemActionBar cho các nút hành động
            ItemActionBar(
              isVisible: !_controller.isSelectMode,
              onShare: () => _shareItem(item),
              onDelete: () => _confirmDelete(item),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSavedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  void _viewItem(FavouriteItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mở bài viết: ${item.title}')),
    );
  }

  void _shareItem(FavouriteItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đang chia sẻ: ${item.title}')),
    );
  }

  void _confirmDelete(FavouriteItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc muốn xóa mục này khỏi danh sách yêu thích?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _controller.deleteFavouriteItem(item);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Đã xóa khỏi danh sách yêu thích'),
                    action: SnackBarAction(
                      label: 'Hoàn tác',
                      onPressed: () {
                        setState(() {
                          _controller.favourites.add(item);
                        });
                      },
                    ),
                  ),
                );
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Sắp xếp theo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Mới nhất trước'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _controller.sortByDate(true);
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Cũ nhất trước'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _controller.sortByDate(false);
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Theo tiêu đề (A-Z)'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _controller.sortByTitle(true);
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Theo tiêu đề (Z-A)'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _controller.sortByTitle(false);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}