import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/find_controller.dart';
import 'page_article.dart';

class PageFind extends StatelessWidget {
  const PageFind({super.key});

  @override
  Widget build(BuildContext context) {
    final FindController findController = Get.put(FindController());

    return Scaffold(
      appBar: AppBar(
        title: _SearchField(
          onChanged: findController.onSearchChanged,
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Obx(() {
          if (findController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (findController.searchQuery.isEmpty) {
            return const Center(
              child: Text('Nhập từ khóa để tìm kiếm'),
            );
          }

          return CustomScrollView(
            slivers: [
              // Topics section
              if (findController.topics.isNotEmpty) ...[
                const SliverPadding(
                  padding: EdgeInsets.all(16.0),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Chủ đề',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final topic = findController.topics[index];
                      return ListTile(
                        leading: topic.topicImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  topic.topicImage!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.topic),
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Icon(Icons.topic),
                        title: Text(topic.topicName),
                        subtitle: const Text('Chủ đề'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
                        onTap: () {
                          Get.to(() => PageArticle(
                            id: topic.topicId,
                            isTopic: true,
                            title: topic.topicName,
                          ));
                        },
                      );
                    },
                    childCount: findController.topics.length,
                  ),
                ),
              ],

              // Newspapers section
              if (findController.newspapers.isNotEmpty) ...[
                const SliverPadding(
                  padding: EdgeInsets.all(16.0),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Trang báo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final newspaper = findController.newspapers[index];
                      return ListTile(
                        leading: newspaper.newspaperImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  newspaper.newspaperImage!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.newspaper),
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Icon(Icons.newspaper),
                        title: Text(newspaper.newspaperName),
                        subtitle: const Text('Trang báo'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
                        onTap: () {
                          Get.to(() => PageArticle(
                            id: newspaper.newspaperId,
                            isTopic: false,
                            title: newspaper.newspaperName,
                          ));
                        },
                      );
                    },
                    childCount: findController.newspapers.length,
                  ),
                ),
              ],

              // No results
              if (findController.topics.isEmpty &&
                  findController.newspapers.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Không tìm thấy kết quả'),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  final Function(String) onChanged;

  const _SearchField({required this.onChanged});

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
      widget.onChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.0,
      alignment: Alignment.center,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm chủ đề, đầu báo...',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
          suffixIcon: _hasText
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
        ),
        autofocus: true,
      ),
    );
  }
}