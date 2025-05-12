import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../repository/topic_repository_tien.dart';

class TestPageTien extends StatefulWidget {
  const TestPageTien({Key? key}) : super(key: key);

  @override
  State<TestPageTien> createState() => _TestPageTienState();
}

class _TestPageTienState extends State<TestPageTien> {
  late final TopicRepository _repository;
  List<TopicRow> _topics = [];
  bool _isLoading = true;
  String _error = '';
  int _offset = 0;
  int _limit = 30;

  @override
  void initState() {
    super.initState();
    _repository = TopicRepository(Supabase.instance.client);
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    try {
      setState(() => _isLoading = true);
      final topics = await _repository.getTopics(
        offset: _offset,
        limit: _limit,
      );
      setState(() {
        _topics = topics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _loadMoreTopics() async {
    setState(() => _offset += _limit);
    _loadTopics();
  }

  void _showSearch() async {
    final result = await showSearch<TopicRow?>(
      context: context,
      delegate: TopicSearchDelegate(_repository),
    );

    if (result != null) {
      setState(() {
        _topics = [result];
      });
    } else {
      // Quay lại danh sách ban đầu nếu không chọn gì
      _offset = 0;
      _loadTopics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Page Tiến"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearch,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text('Lỗi: $_error'))
          : ListView.builder(
        itemCount: _topics.length + 1,
        itemBuilder: (context, index) {
          if (index == _topics.length) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _loadMoreTopics,
                child: const Text("Tải thêm"),
              ),
            );
          }
          final topic = _topics[index];
          return ListTile(
            title: Text(topic.topicName),
          );
        },
      ),
    );
  }
}

class TopicSearchDelegate extends SearchDelegate<TopicRow?> {
  final TopicRepository _repository;

  TopicSearchDelegate(this._repository);

  @override
  String get searchFieldLabel => 'Tìm chủ đề...';

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () {
        query = '';
        showSuggestions(context);
      },
    ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("Nhập từ khóa để tìm chủ đề."),
      );
    }

    return FutureBuilder<List<TopicRow>>(
      future: _repository.getTopics(limit: 1000),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        final allTopics = snapshot.data ?? [];

        final suggestions = allTopics
            .where((topic) =>
            topic.topicName.toLowerCase().contains(query.toLowerCase()))
            .toList();

        if (suggestions.isEmpty) {
          return const Center(child: Text('Không tìm thấy gợi ý'));
        }

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final topic = suggestions[index];
            return ListTile(
              title: Text(topic.topicName),
              onTap: () => close(context, topic), // Gửi kết quả về trang chính
            );
          },
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<TopicRow>>(
      future: _repository.getTopics(limit: 1000),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        final allTopics = snapshot.data ?? [];

        final results = allTopics
            .where((topic) =>
            topic.topicName.toLowerCase().contains(query.toLowerCase()))
            .toList();

        if (results.isEmpty) {
          return const Center(child: Text('Không tìm thấy kết quả'));
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final topic = results[index];
            return ListTile(
              title: Text(topic.topicName),
              onTap: () => close(context, topic),
            );
          },
        );
      },
    );
  }
}
