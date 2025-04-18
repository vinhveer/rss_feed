import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/pages/page_choose_topic.dart';
import 'controllers/app_controller.dart';
import 'controllers/color_controller.dart';
import 'app.dart';

void main() {
  // Initialize both controllers
  Get.put(AppController());
  Get.put(ColorController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // Retrieve controllers
  final AppController appController = Get.find<AppController>();
  final ColorController colorController = Get.find<ColorController>();

  @override
  Widget build(BuildContext context) {
    // Listen to both theme and primary color changes
    return Obx(() {
      final primary = colorController.currentSwatch;
      final mode = colorController.currentThemeMode;

      return GetMaterialApp(
        title: 'RSS Feed App',
        debugShowCheckedModeBanner: false,

        // Light theme
        theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.light(primary: primary),
          appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: primary,
          ),
        ),

        // Dark theme
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: primary,
          colorScheme: ColorScheme.dark(primary: primary),
          appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: primary,
          ),
        ),

        themeMode: mode,
        home: PageChooseTopic(),
      );
    });
  }
}
