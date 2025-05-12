import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/controllers/app_controller.dart';

class App extends StatelessWidget {
  final AppController appController = Get.find();

  App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => appController.currentPage),
      bottomNavigationBar: Obx(
            () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          iconSize: 30.0,
          currentIndex: appController.currentIndex,
          onTap: appController.changePage,
          selectedLabelStyle: const TextStyle(fontSize: 10.0),
          unselectedLabelStyle: const TextStyle(fontSize: 10.0),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.compass_calibration_outlined),
              label: 'Khám phá',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              label: 'Yêu thích',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Cài đặt',
            ),
          ],
        ),
      ),
    );
  }
}
