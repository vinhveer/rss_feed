import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'controllers/app_controller.dart';
import 'controllers/color_controller.dart';
import 'controllers/auth_controller.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://gykrrtrxzocmjusucnmj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd5a3JydHJ4em9jbWp1c3Vjbm1qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ0MzA1ODMsImV4cCI6MjA2MDAwNjU4M30.d5Q8Qzm9yeBaTSM9vOjK-7jGMznnbGUD7HfIzJTdJAE',
  );

  // Initialize controllers
  Get.put(AppController(), permanent: true);
  Get.put(ColorController(), permanent: true);
  final authController = Get.put(AuthController(), permanent: true);

  runApp(const MyApp());
}

// Global Supabase client for app-wide use
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorController = Get.find<ColorController>();

    return Obx(() {
      final primary = colorController.currentSwatch;
      final mode = colorController.currentThemeMode;

      return GetMaterialApp(
        title: 'RSS Feed App',
        debugShowCheckedModeBanner: false,
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
        darkTheme: ThemeData(
          brightness: Brightness.dark,
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
        home: App(),
      );
    });
  }
}