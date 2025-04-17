import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/app.dart';
import 'package:rss_feed/controllers/app_controller.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AppController appController = Get.put(AppController());

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final primary = appController.primarySwatch;
      return GetMaterialApp(
        title: 'RSS Feed App',
        debugShowCheckedModeBanner: false,

        // Light theme
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: primary,
          colorScheme: ColorScheme.light(primary: primary),
          appBarTheme: AppBarTheme(
            backgroundColor: primary,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
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
            backgroundColor: primary,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: primary,
          ),
        ),

        themeMode: appController.themeMode,
        home: App(),
      );
    });
  }
}
