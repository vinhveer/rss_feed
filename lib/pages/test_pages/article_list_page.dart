import 'package:flutter/material.dart';
import 'package:rss_feed/repository/article_repository.dart';
import 'package:rss_feed/row_row_row_generated/tables/article.row.dart';

class ArticleListPage extends StatefulWidget {
  final String initialCategory;
  final String initialNewspaper;
  final String initialSearchQuery;

  const ArticleListPage({
    Key? key,
    this.initialCategory = '',
    this.initialNewspaper = '',
    this.initialSearchQuery = '',
  }) : super(key: key);

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  final ArticleRepository _articleRepository = ArticleRepository();

  List<ArticleRow> _allArticles = [];
  List<ArticleRow> _displayedArticles = [];

  bool _isLoading = false;
  String _errorMessage = '';

  int _offset = 0;
  int _limit = 10;
  String _searchQuery = '';
  String _selectedCategory = '';
  String _selectedNewspaper = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _selectedNewspaper = widget.initialNewspaper;
    _searchQuery = widget.initialSearchQuery;
    _searchController.text = widget.initialSearchQuery;
    _fetchAllArticles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllArticles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final allArticles = await _articleRepository.getAllArticles().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Kết nối hết thời gian sau 20 giây');
        },
      );

      _allArticles = allArticles;
      var filteredArticles = _allArticles;

      if (_searchQuery.isNotEmpty) {
        filteredArticles = filteredArticles.where((article) =>
        (article.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (article.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
        ).toList();
      }

      if (_selectedCategory.isNotEmpty) {
        filteredArticles = filteredArticles.where((article) {
          final content = ((article.title ?? '') + (article.description ?? '')).toLowerCase();
          return content.contains(_selectedCategory.toLowerCase());
        }).toList();
      }

      if (_selectedNewspaper.isNotEmpty) {
        filteredArticles = filteredArticles.where((article) {
          final content = ((article.link ?? '') + (article.title ?? '')).toLowerCase();
          return content.contains(_selectedNewspaper.toLowerCase());
        }).toList();
      }

      final int endIndex = _offset + _limit;
      if (_offset >= filteredArticles.length) {
        _displayedArticles = [];
      } else {
        _displayedArticles = filteredArticles.sublist(
          _offset,
          endIndex < filteredArticles.length ? endIndex : filteredArticles.length,
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải bài báo: ${e.toString()}';
        _isLoading = false;
        _displayedArticles = [];
      });
    }
  }

  int get _currentPage => (_offset ~/ _limit) + 1;

  int get _totalPages {
    int filteredCount = _allArticles.length;
    if (_searchQuery.isNotEmpty) {
      filteredCount = _allArticles.where((article) =>
      (article.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (article.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).length;
    }
    if (_selectedCategory.isNotEmpty) {
      filteredCount = _allArticles.where((article) {
        final content = ((article.title ?? '') + (article.description ?? '')).toLowerCase();
        return content.contains(_selectedCategory.toLowerCase());
      }).length;
    }
    if (_selectedNewspaper.isNotEmpty) {
      filteredCount = _allArticles.where((article) {
        final content = ((article.link ?? '') + (article.title ?? '')).toLowerCase();
        return content.contains(_selectedNewspaper.toLowerCase());
      }).length;
    }
    return (filteredCount / _limit).ceil();
  }

  bool get _hasNextPage => _currentPage < _totalPages;
  bool get _hasPreviousPage => _currentPage > 1;

  void _loadNextPage() {
    setState(() {
      _offset += _limit;
    });
    _fetchAllArticles();
  }

  void _loadPreviousPage() {
    setState(() {
      _offset = (_offset - _limit).clamp(0, double.infinity).toInt();
    });
    _fetchAllArticles();
  }

  void _resetPagination() {
    setState(() {
      _offset = 0;
      _selectedCategory = '';
      _selectedNewspaper = '';
    });
    _fetchAllArticles();
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      _offset = 0;
    });
    _fetchAllArticles();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showArticleDetails(BuildContext context, ArticleRow article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article.title ?? 'Không có tiêu đề',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (article.pubDate != null)
                    Text(
                      'Xuất bản: ${_formatDate(article.pubDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    article.description ?? 'Không có mô tả',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  if (article.link != null)
                    ElevatedButton(
                      onPressed: () {
                        print('Mở URL bài báo: ${article.link}');
                      },
                      child: const Text('Đọc Bài Đầy Đủ'),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildArticleList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _displayedArticles.length,
      itemBuilder: (context, index) {
        final article = _displayedArticles[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.article,
                color: Colors.grey.shade600,
              ),
            ),
            title: Text(
              article.title ?? 'Chưa có tiêu đề',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (article.description != null && article.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      article.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (article.pubDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Xuất bản: ${_formatDate(article.pubDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
            onTap: () => _showArticleDetails(context, article),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách báo"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetPagination,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh tìm kiếm
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm chủ đề hoặc trang báo...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _updateSearchQuery('');
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: _updateSearchQuery,
              ),
              const SizedBox(height: 16),
              // Phân trang và thông tin
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Trang $_currentPage / $_totalPages'),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _hasPreviousPage ? _loadPreviousPage : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: _hasNextPage ? _loadNextPage : null,
                      ),
                    ],
                  ),
                ],
              ),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.red.shade50,
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                )
              else if (_displayedArticles.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Không tìm thấy báo nào'),
                  )
                else
                  _buildArticleList(),
              if (!_isLoading && _displayedArticles.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _hasPreviousPage ? _loadPreviousPage : null,
                        child: const Text('Trang Trước'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _hasNextPage ? _loadNextPage : null,
                        child: const Text('Trang Tiếp'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}