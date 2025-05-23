import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/controllers/color_controller.dart';
import 'package:rss_feed/controllers/explore_controller.dart';
import 'package:rss_feed/pages/explore_pages/page_find.dart';

class PageExplore extends StatelessWidget {
  const PageExplore({super.key});

  @override
  Widget build(BuildContext context) {
    final ExploreController exploreController = Get.put(ExploreController());
    // Lấy màu primary từ colorController
    final primary = Get.find<ColorController>().currentSwatch;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Khám phá",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Obx(() {
        if (exploreController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh tìm kiếm dạng nút bấm
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: () {
                    Get.to(() => PageFind());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey.shade600),
                        const SizedBox(width: 8.0),
                        Text(
                          "Tìm kiếm chủ đề hoặc trang báo ...",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Phần 1: Chủ đề nổi bật
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Chủ đề nổi bật",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Grid view cho chủ đề
              GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.5,
                ),
                itemCount: exploreController.topics.length,
                itemBuilder: (context, index) {
                  final topic = exploreController.topics[index];
                  return InkWell(
                    onTap: () {
                      // Get.to(() => PageArticle(
                      //   id: topic.topicId.toString(),
                      //   isTopic: true,
                      //   title: topic.topicName,
                      // ));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: primary.withOpacity(0.7)),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.15),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (topic.topicImage != null)
                            Image.network(
                              topic.topicImage!,
                              width: 36,
                              height: 36,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.topic, size: 36.0),
                            )
                          else
                            const Icon(Icons.topic, size: 36.0),
                          const SizedBox(height: 8.0),
                          Text(
                            topic.topicName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24.0),

              // Phần 2: Đầu báo nổi bật
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Đầu báo nổi bật",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // List view cho đầu báo
              ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: exploreController.newspapers.length,
                itemBuilder: (context, index) {
                  final newspaper = exploreController.newspapers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: primary.withOpacity(0.7)),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.15),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
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
                              ),
                            )
                          : const Icon(Icons.newspaper),
                      title: Text(
                        newspaper.newspaperName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Get.to(() => PageArticle(
                        //   id: newspaper.newspaperId.toString(),
                        //   isTopic: false,
                        //   title: newspaper.newspaperName,
                        // ));
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 24.0),
            ],
          ),
        );
      }),
    );
  }
}