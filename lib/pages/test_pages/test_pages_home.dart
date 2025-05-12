import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/pages/test_pages/test_page_my.dart';
import 'package:rss_feed/pages/test_pages/test_page_thuy.dart';
import 'package:rss_feed/pages/test_pages/test_page_tien.dart';
import 'package:rss_feed/pages/test_pages/test_repository_tien.dart';
import 'package:rss_feed/pages/test_pages/test_page_vinh.dart';

class TestPagesHome extends StatelessWidget {
  const TestPagesHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test pages"),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () => Get.to(TestPageVinh()),
                child: Text("Trang test của Vinh")
            ),
            ElevatedButton(
                onPressed: () => Get.to(TestPageTien()),
                child: Text("Trang test của Tien")
            ),
            ElevatedButton(
                onPressed: () => Get.to(TestPageThuy()),
                child: Text("Trang test của Thuy")
            ),
            ElevatedButton(
                onPressed: () => Get.to(TestPageMy()),
                child: Text("Trang test của My")
            )
          ],
        ),
      ),
    );
  }
}
