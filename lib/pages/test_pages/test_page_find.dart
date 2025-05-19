import 'package:flutter/material.dart';
import 'article_list_page.dart';

class TestPageFind extends StatefulWidget {
  const TestPageFind({super.key});

  @override
  State<TestPageFind> createState() => _TestPageFindState();
}

class _TestPageFindState extends State<TestPageFind> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _suggestions = [
    {'title': 'Thời sự', 'type': 'Chủ đề'},
    {'title': 'Thể thao', 'type': 'Chủ đề'},
    {'title': 'VnExpress', 'type': 'Trang báo'},
    {'title': 'Tuổi Trẻ', 'type': 'Trang báo'},
    {'title': 'Giải trí', 'type': 'Chủ đề'},
    {'title': 'Kinh doanh', 'type': 'Chủ đề'},
    {'title': 'Thanh Niên', 'type': 'Trang báo'},
    {'title': 'Dân Trí', 'type': 'Trang báo'},
    {'title': 'Công nghệ', 'type': 'Chủ đề'},
    {'title': 'Người Lao Động', 'type': 'Trang báo'},
  ];
  List<Map<String, String>> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _filteredSuggestions = _suggestions;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final keyword = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredSuggestions = keyword.isEmpty
          ? _suggestions
          : _suggestions
          .where((item) =>
      item['title']!.toLowerCase().contains(keyword) ||
          item['type']!.toLowerCase().contains(keyword))
          .toList();
    });
  }

  void _onResultTap(Map<String, String> result) {
    if (result['type'] == 'Chủ đề') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ArticleListPage(initialCategory: result['title'] ?? ''),
        ),
      );
    } else if (result['type'] == 'Trang báo') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ArticleListPage(initialNewspaper: result['title'] ?? ''),
        ),
      );
    }
  }

  void _onSubmit(String value) {
    String trimmed = value.trim();
    if (trimmed.isEmpty) return;
    // Nếu khớp với chủ đề hoặc trang báo trong suggestions thì chuyển tiếp theo loại
    final found = _suggestions.firstWhere(
          (item) => item['title']!.toLowerCase() == trimmed.toLowerCase(),
      orElse: () => {},
    );
    if (found.isNotEmpty) {
      _onResultTap(found);
      return;
    }
    // Không khớp thì tìm kiếm tất cả bài báo liên quan đến từ khóa
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleListPage(initialSearchQuery: trimmed),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _SearchField(
          controller: _searchController,
          onSubmitted: _onSubmit,
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _SearchResults(
        searchResults: _filteredSuggestions,
        onTapResult: _onResultTap,
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;

  const _SearchField({required this.controller, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.0,
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm chủ đề, đầu báo...',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              controller.clear();
            },
          )
              : null,
        ),
        autofocus: true,
        onSubmitted: onSubmitted,
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<Map<String, String>> searchResults;
  final Function(Map<String, String>) onTapResult;

  const _SearchResults({
    required this.searchResults,
    required this.onTapResult,
  });

  @override
  Widget build(BuildContext context) {
    if (searchResults.isEmpty) {
      return const Center(
        child: Text("Không tìm thấy kết quả phù hợp."),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final result = searchResults[index];
        return ListTile(
          title: Text(result['title']!),
          subtitle: Text(
            result['type']!,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12.0,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
          onTap: () => onTapResult(result),
        );
      },
    );
  }
}