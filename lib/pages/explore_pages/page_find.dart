import 'package:flutter/material.dart';

class PageFind extends StatelessWidget {
  const PageFind({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _SearchField(),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _SearchResults(),
    );
  }
}

class _SearchField extends StatefulWidget {
  @override
  _SearchFieldState createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _hasText = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sửa lỗi chữ bị nhảy bằng cách giữ chiều cao cố định
    return Container(
      height: 48.0, // Chiều cao cố định
      alignment: Alignment.center,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm chủ đề, đầu báo...',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
          suffixIcon: _hasText ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
            },
          ) : null,
        ),
        autofocus: true,
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final searchResults = [
      {'title': 'Thời sự', 'type': 'Chủ đề'},
      {'title': 'Thể thao', 'type': 'Chủ đề'},
      {'title': 'VnExpress', 'type': 'Trang báo'},
      {'title': 'Tuổi Trẻ', 'type': 'Trang báo'},
    ];

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final result = searchResults[index];
        return ListTile(
          title: Text(result['title'] as String),
          subtitle: Text(
            result['type'] as String,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12.0,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
          onTap: () {},
        );
      },
    );
  }
}