import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/controllers/color_controller.dart';
import 'package:rss_feed/controllers/explore_controller.dart';
import 'package:rss_feed/pages/explore_pages/page_find.dart';
import 'package:rss_feed/pages/explore_pages/page_article.dart';

class PageExplore extends StatelessWidget {
  const PageExplore({super.key});

  @override
  Widget build(BuildContext context) {
    final ExploreController exploreController = Get.put(ExploreController());
    // Lấy màu primary từ colorController
    final primary = Get.find<ColorController>().currentSwatch;
    final RxBool isLoadingImages = true.obs;

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

        return Stack(
          children: [
            SingleChildScrollView(
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
                          Get.to(() => PageArticle(
                            id: topic.topicId,
                            isTopic: true,
                            title: topic.topicName,
                          ));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: primary.withAlpha(179)),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withAlpha(38),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Background image or gradient
                              Positioned.fill(
                                child: topic.topicImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: Image.network(
                                          topic.topicImage!,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              if (index == exploreController.topics.length - 1) {
                                                Future.delayed(const Duration(milliseconds: 100), () {
                                                  isLoadingImages.value = false;
                                                });
                                              }
                                              return child;
                                            }
                                            return Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    primary.withAlpha(38),
                                                    primary.withAlpha(25),
                                                  ],
                                                ),
                                              ),
                                              child: Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                      : null,
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(primary),
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) =>
                                              Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      primary.withAlpha(38),
                                                      primary.withAlpha(25),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              primary.withAlpha(38),
                                              primary.withAlpha(25),
                                            ],
                                          ),
                                        ),
                                      ),
                              ),
                              // Semi-transparent overlay for better text readability
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withAlpha(128),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Content
                              Positioned(
                                bottom: 12,
                                left: 12,
                                right: 12,
                                child: Text(
                                  topic.topicName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
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

                  // Grid view cho đầu báo
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
                    itemCount: exploreController.newspapers.length,
                    itemBuilder: (context, index) {
                      final newspaper = exploreController.newspapers[index];
                      return InkWell(
                        onTap: () {
                          Get.to(() => PageArticle(
                            id: newspaper.newspaperId,
                            isTopic: false,
                            title: newspaper.newspaperName,
                          ));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: primary.withAlpha(179)),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withAlpha(38),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Background image or gradient
                              Positioned.fill(
                                child: newspaper.newspaperImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: Image.network(
                                          newspaper.newspaperImage!,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              if (index == exploreController.newspapers.length - 1) {
                                                Future.delayed(const Duration(milliseconds: 100), () {
                                                  isLoadingImages.value = false;
                                                });
                                              }
                                              return child;
                                            }
                                            return Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    primary.withAlpha(38),
                                                    primary.withAlpha(25),
                                                  ],
                                                ),
                                              ),
                                              child: Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                      : null,
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(primary),
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) =>
                                              Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      primary.withAlpha(38),
                                                      primary.withAlpha(25),
                                                    ],
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    newspaper.newspaperName.substring(0, 1).toUpperCase(),
                                                    style: TextStyle(
                                                      color: primary,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 32,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              primary.withAlpha(38),
                                              primary.withAlpha(25),
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            newspaper.newspaperName.substring(0, 1).toUpperCase(),
                                            style: TextStyle(
                                              color: primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 32,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              // Semi-transparent overlay for better text readability
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withAlpha(128),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Content
                              Positioned(
                                bottom: 12,
                                left: 12,
                                right: 12,
                                child: Text(
                                  newspaper.newspaperName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24.0),
                ],
              ),
            ),
            Obx(() => isLoadingImages.value
                ? Container(
                    color: Colors.white,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        );
      }),
    );
  }
}