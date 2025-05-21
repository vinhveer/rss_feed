import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'controllers/app_controller.dart';
import 'controllers/article_favourite_controller.dart';
import 'controllers/color_controller.dart';
import 'controllers/auth_controller.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize controllers
  Get.put(AppController(), permanent: true);
  Get.put(ColorController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(ArticleFavouriteController());

  runApp(const MyApp());
}

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