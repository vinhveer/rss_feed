import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/favourite_controller.dart';

class PageFavourite extends StatefulWidget {
  final String userId;

  const PageFavourite({super.key, required this.userId});

  @override
  State<PageFavourite> createState() => _PageFavouriteState();
}

enum SortOption { aToZ, zToA, newest, oldest }

class _PageFavouriteState extends State<PageFavourite> {
  late final FavouriteController _controller;
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey();
  SortOption _sortOption = SortOption.newest;

  @override
  void initState() {
    super.initState();
    _controller = FavouriteController(userId: widget.userId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavourites();
    });
  }

  Future<void> _loadFavourites() async {
    try {
      await _controller.loadFavourites();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
        );
      }
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _controller.isSelectMode
            ? Text('Đã chọn ${_controller.selectedItems.length} mục')
            : const Text('Danh mục yêu thích'),
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Sắp xếp',
            onSelected: (option) {
              setState(() {
                _sortOption = option;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: SortOption.aToZ, child: Text('A → Z')),
              const PopupMenuItem(value: SortOption.zToA, child: Text('Z → A')),
              const PopupMenuItem(value: SortOption.newest, child: Text('Mới nhất')),
              const PopupMenuItem(value: SortOption.oldest, child: Text('Cũ nhất')),
            ],
          ),
          ..._buildAppBarActions(),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _loadFavourites,
        child: _controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildFavouritesList(),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_controller.isSelectMode) {
      return [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _controller.selectedItems.isNotEmpty
              ? () async {
            try {
              await _controller.deleteSelected();
              if (mounted) setState(() {});
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi khi xóa: $e')),
                );
              }
            }
          }
              : null,
          tooltip: 'Xóa các mục đã chọn',
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _controller.cancelSelection();
            setState(() {});
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
            _controller.enableSelectMode();
            setState(() {});
          }
              : null,
          tooltip: 'Chọn nhiều',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            _refreshKey.currentState?.show();
          },
          tooltip: 'Làm mới',
        ),
      ];
    }
  }

  Widget _buildFavouritesList() {
    if (_controller.favourites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Chưa có bài viết yêu thích',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _loadFavourites,
              icon: const Icon(Icons.refresh),
              label: const Text('Làm mới'),
            ),
          ],
        ),
      );
    }

    var sortedList = List<FavouriteItem>.from(_controller.favourites);

    switch (_sortOption) {
      case SortOption.aToZ:
        sortedList.sort((a, b) =>
            a.title.trim().toLowerCase().compareTo(b.title.trim().toLowerCase()));
        break;
      case SortOption.zToA:
        sortedList.sort((a, b) =>
            b.title.trim().toLowerCase().compareTo(a.title.trim().toLowerCase()));
        break;
      case SortOption.newest:
        sortedList.sort((a, b) => b.pubDate.compareTo(a.pubDate));
        break;
      case SortOption.oldest:
        sortedList.sort((a, b) => a.pubDate.compareTo(b.pubDate));
        break;
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: sortedList.length,
      itemBuilder: (context, index) {
        final item = sortedList[index];
        return _buildFavouriteCard(item);
      },
    );
  }

  Widget _buildFavouriteCard(FavouriteItem item) {
    final isSelected = _controller.isSelected(item);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (_controller.isSelectMode) {
            _controller.toggleItemSelection(item);
            setState(() {});
          } else {
            _viewItem(item);
          }
        },
        onLongPress: !_controller.isSelectMode
            ? () {
          _controller.enableSelectMode();
          _controller.toggleItemSelection(item);
          setState(() {});
        }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? Image.network(
                  item.imageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                )
                    : Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.description != null && item.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      _formatSavedDate(item.pubDate),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              _controller.isSelectMode
                  ? Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              )
                  : PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'delete':
                      _confirmDelete(item);
                      break;
                    case 'share':
                      _shareItem(item);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share, size: 20),
                        SizedBox(width: 8),
                        Text('Chia sẻ'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20),
                        SizedBox(width: 8),
                        Text('Xóa'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSavedDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays} ngày trước';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  void _viewItem(FavouriteItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Xem bài viết: ${item.title}')),
    );
  }

  void _shareItem(FavouriteItem item) {
    final shareText = '${item.title}\n${item.link}';
    Share.share(shareText, subject: 'Tin tức thú vị hôm nay');
  }

  void _confirmDelete(FavouriteItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa mục này khỏi yêu thích?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final deletedItem = FavouriteItem(
                id: item.id,
                userId: item.userId,
                title: item.title,
                description: item.description,
                imageUrl: item.imageUrl,
                link: item.link,
                pubDate: item.pubDate,
              );

              try {
                await _controller.deleteFavouriteItem(item);
                setState(() {});
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Đã xóa khỏi yêu thích'),
                      action: SnackBarAction(
                        label: 'Hoàn tác',
                        onPressed: () async {
                          try {
                            await _controller.undoDelete(deletedItem);
                            setState(() {});
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lỗi khi hoàn tác: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi xóa: $e')),
                  );
                }
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
