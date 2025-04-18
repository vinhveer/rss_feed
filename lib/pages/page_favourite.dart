import 'package:flutter/material.dart';

class FavouriteItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final DateTime savedDate;
  bool isSelected;

  FavouriteItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.savedDate,
    this.isSelected = false,
  });
}

class PageFavourite extends StatefulWidget {
  const PageFavourite({super.key});

  @override
  State<PageFavourite> createState() => _PageFavouriteState();
}

class _PageFavouriteState extends State<PageFavourite> {
  String _selectedFilter = 'Tất cả';
  bool _isSelectMode = false;
  List<String> _categories = [
    'Tất cả',
    'Thể thao',
    'Giải trí',
    'Khoa học',
    'Công nghệ',
    'Âm nhạc',
  ];

  final List<FavouriteItem> _favourites = [
    FavouriteItem(
      id: '1',
      title: 'Khám phá vùng biển sâu: Những sinh vật kỳ lạ dưới đáy đại dương',
      description: 'Các nhà khoa học phát hiện nhiều loài sinh vật mới chưa từng được biết đến tại vùng biển sâu.',
      category: 'Khoa học',
      imageUrl: 'assets/images/ocean.jpg',
      savedDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    FavouriteItem(
      id: '2',
      title: 'Đội tuyển Việt Nam chuẩn bị cho vòng loại World Cup 2026',
      description: 'HLV trưởng công bố danh sách 26 cầu thủ cho các trận đấu sắp tới.',
      category: 'Thể thao',
      imageUrl: 'assets/images/football_team.jpg',
      savedDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
    FavouriteItem(
      id: '3',
      title: 'Top 10 phim đáng chờ đợi nhất năm 2025',
      description: 'Những bom tấn Hollywood và các tác phẩm điện ảnh độc lập được mong chờ nhất.',
      category: 'Giải trí',
      imageUrl: 'assets/images/movies.jpg',
      savedDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    FavouriteItem(
      id: '4',
      title: 'Xu hướng công nghệ AI mới nhất trong năm 2025',
      description: 'Trí tuệ nhân tạo đang thay đổi cách chúng ta làm việc và sống như thế nào.',
      category: 'Công nghệ',
      imageUrl: 'assets/images/ai_tech.jpg',
      savedDate: DateTime.now().subtract(const Duration(days: 3)),
    ),
    FavouriteItem(
      id: '5',
      title: 'Festival âm nhạc quốc tế sẽ diễn ra tại Hà Nội vào tháng 6',
      description: 'Hàng loạt nghệ sĩ hàng đầu thế giới xác nhận tham gia sự kiện âm nhạc lớn nhất năm.',
      category: 'Âm nhạc',
      imageUrl: 'assets/images/music_festival.jpg',
      savedDate: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  List<FavouriteItem> get filteredFavourites {
    if (_selectedFilter == 'Tất cả') {
      return _favourites;
    } else {
      return _favourites.where((item) => item.category == _selectedFilter).toList();
    }
  }

  int get selectedCount {
    return _favourites.where((item) => item.isSelected).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelectMode
            ? Text('Đã chọn $selectedCount mục')
            : const Text('Yêu thích'),
        actions: _buildAppBarActions(),
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: _buildFavouritesList(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isSelectMode) {
      return [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: selectedCount > 0 ? _deleteSelected : null,
          tooltip: 'Xóa các mục đã chọn',
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: _cancelSelection,
          tooltip: 'Hủy chọn',
        ),
      ];
    } else {
      return [
        IconButton(
          icon: const Icon(Icons.select_all),
          onPressed: _favourites.isNotEmpty ? _enableSelectMode : null,
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

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedFilter == category;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = category;
                  });
                }
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavouritesList() {
    if (filteredFavourites.isEmpty) {
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
              _selectedFilter == 'Tất cả'
                  ? 'Chưa có mục yêu thích nào'
                  : 'Chưa có mục yêu thích nào trong $_selectedFilter',
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
      itemCount: filteredFavourites.length,
      itemBuilder: (context, index) {
        final item = filteredFavourites[index];
        return _buildFavouriteCard(item);
      },
    );
  }

  Widget _buildFavouriteCard(FavouriteItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _isSelectMode ? () => _toggleItemSelection(item) : () => _viewItem(item),
        onLongPress: !_isSelectMode ? () => _toggleItemSelection(item) : null,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(
                          _getCategoryIcon(item.category),
                          size: 48,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_isSelectMode)
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
                          item.isSelected ? Icons.check : Icons.circle_outlined,
                          size: 20,
                          color: item.isSelected ? Colors.white : Colors.grey[600],
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: TextStyle(
                      color: Colors.grey[700],
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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
            if (!_isSelectMode)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () => _shareItem(item),
                      tooltip: 'Chia sẻ',
                      iconSize: 20,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmDelete(item),
                      tooltip: 'Xóa khỏi yêu thích',
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Thể thao':
        return Icons.sports_soccer;
      case 'Giải trí':
        return Icons.movie;
      case 'Khoa học':
        return Icons.science;
      case 'Công nghệ':
        return Icons.computer;
      case 'Âm nhạc':
        return Icons.music_note;
      default:
        return Icons.article;
    }
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
    // Implement navigation to detail page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mở bài viết: ${item.title}')),
    );
  }

  void _shareItem(FavouriteItem item) {
    // Implement share functionality
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
                _deleteFavouriteItem(item);
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _deleteFavouriteItem(FavouriteItem item) {
    setState(() {
      _favourites.removeWhere((favItem) => favItem.id == item.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã xóa khỏi danh sách yêu thích'),
        action: SnackBarAction(
          label: 'Hoàn tác',
          onPressed: () {
            setState(() {
              _favourites.add(item);
            });
          },
        ),
      ),
    );
  }

  void _toggleItemSelection(FavouriteItem item) {
    setState(() {
      if (!_isSelectMode) {
        _isSelectMode = true;
        item.isSelected = true;
      } else {
        item.isSelected = !item.isSelected;
        // If no items are selected anymore, exit select mode
        if (selectedCount == 0) {
          _isSelectMode = false;
        }
      }
    });
  }

  void _enableSelectMode() {
    setState(() {
      _isSelectMode = true;
    });
  }

  void _cancelSelection() {
    setState(() {
      for (var item in _favourites) {
        item.isSelected = false;
      }
      _isSelectMode = false;
    });
  }

  void _deleteSelected() {
    final selectedItems = _favourites.where((item) => item.isSelected).toList();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc muốn xóa ${selectedItems.length} mục đã chọn khỏi danh sách yêu thích?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _favourites.removeWhere((item) => item.isSelected);
                  _isSelectMode = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa ${selectedItems.length} mục khỏi danh sách yêu thích'),
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
                  _sortByDate(true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Cũ nhất trước'),
                onTap: () {
                  Navigator.pop(context);
                  _sortByDate(false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Theo tiêu đề (A-Z)'),
                onTap: () {
                  Navigator.pop(context);
                  _sortByTitle(true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Theo tiêu đề (Z-A)'),
                onTap: () {
                  Navigator.pop(context);
                  _sortByTitle(false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _sortByDate(bool newestFirst) {
    setState(() {
      if (newestFirst) {
        _favourites.sort((a, b) => b.savedDate.compareTo(a.savedDate));
      } else {
        _favourites.sort((a, b) => a.savedDate.compareTo(b.savedDate));
      }
    });
  }

  void _sortByTitle(bool ascending) {
    setState(() {
      if (ascending) {
        _favourites.sort((a, b) => a.title.compareTo(b.title));
      } else {
        _favourites.sort((a, b) => b.title.compareTo(a.title));
      }
    });
  }
}