import 'package:flutter/material.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'Tất cả',
    'Nóng',
    'Thể thao',
    'Giải trí',
    'Khoa học',
    'Âm nhạc',
    'Trò chơi',
    'Tin tức',
    'Công nghệ',
  ];

  final List<FeedItem> _feedItems = [
    FeedItem(
      title: 'NASA phát hiện hành tinh mới có khả năng chứa sự sống',
      source: 'Khoa học Việt Nam',
      timeAgo: '2 giờ trước',
      imageUrl: 'assets/images/planet.jpg',
      category: 'Khoa học',
    ),
    FeedItem(
      title: 'Giải vô địch bóng đá thế giới 2026 sẽ được tổ chức tại đâu?',
      source: 'Thể thao 24h',
      timeAgo: '5 giờ trước',
      imageUrl: 'assets/images/football.jpg',
      category: 'Thể thao',
    ),
    FeedItem(
      title: 'Album mới của Taylor Swift phá vỡ kỷ lục trên các nền tảng nghe nhạc',
      source: 'Âm nhạc Plus',
      timeAgo: '1 ngày trước',
      imageUrl: 'assets/images/music.jpg',
      category: 'Giải trí',
    ),
    FeedItem(
      title: 'Xu hướng AI mới nhất năm 2025 bạn cần biết',
      source: 'Tech Review',
      timeAgo: '3 giờ trước',
      imageUrl: 'assets/images/ai.jpg',
      category: 'Công nghệ',
    ),
    FeedItem(
      title: 'Top 10 điểm du lịch hot nhất mùa hè 2025',
      source: 'Travel & Life',
      timeAgo: '6 giờ trước',
      imageUrl: 'assets/images/travel.jpg',
      category: 'Nóng',
    ),
  ];

  List<FeedItem> get filteredFeedItems {
    if (_selectedCategoryIndex == 0) {
      return _feedItems;
    } else {
      return _feedItems
          .where((item) => item.category == _categories[_selectedCategoryIndex])
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildCategoriesBar(),
          Expanded(
            child: _buildFeedList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(_categories[index]),
              selected: _selectedCategoryIndex == index,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategoryIndex = index;
                  });
                }
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: _selectedCategoryIndex == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
                fontWeight: _selectedCategoryIndex == index
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: _selectedCategoryIndex == index
                      ? Theme.of(context).primaryColor
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              backgroundColor: Colors.transparent,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeedList() {
    return filteredFeedItems.isEmpty
        ? Center(
      child: Text(
        'Không có nội dung cho chủ đề ${_categories[_selectedCategoryIndex]}',
        style: TextStyle(color: Colors.grey[600]),
      ),
    )
        : ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredFeedItems.length,
      itemBuilder: (context, index) {
        final item = filteredFeedItems[index];
        return _buildFeedCard(item);
      },
    );
  }

  Widget _buildFeedCard(FeedItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.grey[300],
                child: Center(
                  child: Icon(
                    _getIconForCategory(item.category),
                    size: 48,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
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
                Row(
                  children: [
                    Text(
                      item.source,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.timeAgo,
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Thể thao':
        return Icons.sports_soccer;
      case 'Giải trí':
        return Icons.movie;
      case 'Khoa học':
        return Icons.science;
      case 'Âm nhạc':
        return Icons.music_note;
      case 'Trò chơi':
        return Icons.games;
      case 'Tin tức':
        return Icons.newspaper;
      case 'Công nghệ':
        return Icons.computer;
      case 'Nóng':
        return Icons.local_fire_department;
      default:
        return Icons.article;
    }
  }
}

class FeedItem {
  final String title;
  final String source;
  final String timeAgo;
  final String imageUrl;
  final String category;

  FeedItem({
    required this.title,
    required this.source,
    required this.timeAgo,
    required this.imageUrl,
    required this.category,
  });
}