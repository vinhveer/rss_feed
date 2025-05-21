import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/controllers/reading_controller.dart';
import '../../controllers/article_favourite_controller.dart';

class ReadingButton extends StatefulWidget {
  final ReadingController controller;
  final String url;
  final bool isVn;
  final int articleId;

  const ReadingButton({
    super.key,
    required this.controller,
    required this.url,
    required this.isVn,
    required this.articleId,
  });

  @override
  State<ReadingButton> createState() => _ReadingButtonState();
}

class _ReadingButtonState extends State<ReadingButton> {
  bool isFavourited = false;
  final ArticleFavouriteController _favouriteController = ArticleFavouriteController();

  @override
  void initState() {
    super.initState();
    _loadFavouriteStatus();
  }

  Future<void> _loadFavouriteStatus() async {
    final status = await _favouriteController.isFavourited(widget.articleId);
    if (mounted) {
      setState(() {
        isFavourited = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.controller.isReading.value) {
        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  DropdownButton<double>(
                    value: widget.controller.speechRate.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    underline: const SizedBox(),
                    onChanged: (value) {
                      if (value != null) {
                        widget.controller.setSpeechRate(value);
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 0.5, child: Text("0.5x")),
                      DropdownMenuItem(value: 1.0, child: Text("1x")),
                      DropdownMenuItem(value: 1.5, child: Text("1.5x")),
                      DropdownMenuItem(value: 2.0, child: Text("2x")),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10),
                    tooltip: "Lùi lại",
                    onPressed: widget.controller.skipBackward,
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.black87,
                    child: IconButton(
                      icon: const Icon(Icons.pause, color: Colors.white),
                      onPressed: widget.controller.toggleReading,
                      iconSize: 20,
                      tooltip: "Tạm dừng",
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.forward_10),
                    tooltip: "Chuyển tiếp",
                    onPressed: widget.controller.skipForward,
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.controller.stop,
                tooltip: "Dừng đọc",
              ),
            ],
          ),
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                FloatingActionButton(
                  heroTag: 'favorite',
                  onPressed: () async {
                    if (isFavourited) {
                      await _favouriteController.removeFromFavourite(widget.articleId);
                      if (!context.mounted) return;
                      setState(() {
                        isFavourited = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã xóa khỏi mục yêu thích')),
                      );
                    } else {
                      await _favouriteController.addToFavourite(widget.articleId);
                      if (!context.mounted) return;
                      setState(() {
                        isFavourited = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã thêm vào mục yêu thích')),
                      );
                    }
                  },
                  backgroundColor: Colors.white,
                  elevation: 2,
                  child: Icon(
                    isFavourited ? Icons.favorite : Icons.favorite_border,
                    color: isFavourited ? Colors.pink : Colors.black,
                  ),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'not_interested',
                  onPressed: () {
                    _favouriteController.ignoreArticle(widget.articleId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã ẩn bài viết khỏi trang chủ')),
                    );
                    setState(() {});
                  },
                  backgroundColor: Colors.white,
                  elevation: 2,
                  child: const Icon(Icons.block, color: Colors.black),
                ),
              ],
            ),
            FloatingActionButton(
              heroTag: 'read',
              backgroundColor: Colors.blue,
              child: const Icon(Icons.play_arrow, color: Colors.white),
              onPressed: () async {
                await widget.controller.readArticle(widget.url, isVn: widget.isVn);
              },
            ),
          ],
        );
      }
    });
  }
}
