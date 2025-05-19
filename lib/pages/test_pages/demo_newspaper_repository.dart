import 'package:flutter/material.dart';
import 'package:rss_feed/pages/test_pages/test_page_find.dart';

class NewspaperExplorePage extends StatefulWidget {
  const NewspaperExplorePage({Key? key}) : super(key: key);

  @override
  State<NewspaperExplorePage> createState() => _NewspaperExplorePageState();
}

class _NewspaperExplorePageState extends State<NewspaperExplorePage> {
  // Danh sách các chủ đề nổi bật
  final List<String> _featuredCategories = [
    'Thời sự',
    'Thể thao',
    'Giải trí',
    'Kinh doanh',
    'Công nghệ',
  ];

  // Danh sách các đầu báo nổi bật
  final List<String> _featuredNewspapers = [
    'VnExpress',
    'Tuổi Trẻ',
    'Thanh Niên',
    'Dân Trí',
    'Người Lao Động',
  ];

  // Lưu trữ icon cho từng chủ đề
  final Map<String, IconData> _categoryIcons = {
    'Thời sự': Icons.article,
    'Thể thao': Icons.sports_soccer,
    'Giải trí': Icons.movie,
    'Kinh doanh': Icons.business,
    'Công nghệ': Icons.computer,
  };

  // Lưu trữ màu sắc cho từng chủ đề
  final Map<String, Color> _categoryColors = {
    'Thời sự': Colors.blue,
    'Thể thao': Colors.green,
    'Giải trí': Colors.purple,
    'Kinh doanh': Colors.amber,
    'Công nghệ': Colors.red,
  };

  // Lưu trữ icon cho từng đầu báo
  final Map<String, IconData> _newspaperIcons = {
    'VnExpress': Icons.article,
    'Tuổi Trẻ': Icons.menu_book,
    'Thanh Niên': Icons.bookmark,
    'Dân Trí': Icons.library_books,
    'Người Lao Động': Icons.work_outline,
  };

  // Lưu trữ màu sắc cho từng đầu báo
  final Map<String, Color> _newspaperColors = {
    'VnExpress': Colors.red,
    'Tuổi Trẻ': Colors.orange,
    'Thanh Niên': Colors.blue,
    'Dân Trí': Colors.teal,
    'Người Lao Động': Colors.green,
  };

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToFindPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TestPageFind()),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: _navigateToFindPage,
      child: AbsorbPointer(
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm chủ đề hoặc trang báo...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chủ Đề Nổi Bật',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _featuredCategories.length,
            itemBuilder: (context, index) {
              final category = _featuredCategories[index];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _categoryIcons[category] ?? Icons.label,
                          size: 40,
                          color: _categoryColors[category] ?? Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedNewspapersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đầu Báo Nổi Bật',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // Danh sách đầu báo theo chiều dọc, mỗi báo là 1 dòng
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _featuredNewspapers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final newspaper = _featuredNewspapers[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: (_newspaperColors[newspaper] ?? Colors.blue).withOpacity(0.15),
                  child: Icon(
                    _newspaperIcons[newspaper] ?? Icons.public,
                    color: _newspaperColors[newspaper] ?? Colors.blue,
                  ),
                ),
                title: Text(
                  newspaper,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _newspaperColors[newspaper] ?? Colors.blue,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                onTap: _navigateToFindPage,
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Khám phá", style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildFeaturedCategoriesSection(),
              const SizedBox(height: 24),
              _buildFeaturedNewspapersSection(),
            ],
          ),
        ),
      ),
    );
  }
}