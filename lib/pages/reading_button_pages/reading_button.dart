import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/controllers/reading_controller.dart';

class ReadingButton extends StatelessWidget {
  final ReadingController controller;
  final String url;
  const ReadingButton({super.key, required this.controller, required this.url});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isReading.value) {
        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Speed select dropdown
              Row(
                children: [
                  DropdownButton<double>(
                    value: controller.speechRate.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    underline: const SizedBox(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.setSpeechRate(value);
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
                    onPressed: controller.skipBackward,
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.black87,
                    child: IconButton(
                      icon: const Icon(Icons.pause, color: Colors.white),
                      onPressed: controller.toggleReading,
                      iconSize: 20,
                      tooltip: "Tạm dừng",
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.forward_10),
                    tooltip: "Chuyển tiếp",
                    onPressed: controller.skipForward,
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: controller.stop,
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
                  onPressed: () {},
                  backgroundColor: Colors.white,
                  elevation: 2,
                  child: const Icon(Icons.favorite_border, color: Colors.black),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'bookmark',
                  onPressed: () {},
                  backgroundColor: Colors.white,
                  elevation: 2,
                  child: const Icon(Icons.bookmark_border, color: Colors.black),
                ),
              ],
            ),
            FloatingActionButton(
              heroTag: 'read',
              backgroundColor: Colors.blue,
              child: const Icon(Icons.play_arrow, color: Colors.white),
              onPressed: () async {
                await controller.readArticle(url);
              },
            ),
          ],
        );
      }
    });
  }
}