// test/repository/article_repository_test.dart

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rss_feed/repository/article_repository.dart';
import 'package:rss_feed/row_row_row_generated/tables/article.row.dart';

class _PassthroughHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? ctx) =>
      super.createHttpClient(ctx);
}

void main() {
  // 1) allow real HTTP
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _PassthroughHttpOverrides();

  // 2) fake SharedPreferences so supabase_flutter’s GoTrue storage won’t crash
  SharedPreferences.setMockInitialValues({});

  late ArticleRepository repository;

  setUpAll(() async {
    // 3) load your test env file
    await dotenv.load(fileName: '.env');
    final url = dotenv.env['SUPABASE_URL']!;
    final key = dotenv.env['SUPABASE_ANON_KEY']!;

    // 4) init Supabase with real network allowed
    await Supabase.initialize(url: url, anonKey: key);

    // 5) if your RLS policy requires an authenticated user,
    //    set a session from your test refresh token:
    final refresh = dotenv.env['SUPABASE_TEST_REFRESH_TOKEN']!;
    await Supabase.instance.client.auth.setSession(refresh);

    repository = ArticleRepository(client: Supabase.instance.client);
  });

  test('getAllArticles actually fetches from Supabase', () async {
    final list = await repository.getAllArticles();
    expect(list, isA<List<ArticleRow>>());
    expect(list.isNotEmpty, isTrue,
        reason: 'Your articles table must have at least one row');
  });

  test('getArticlesByRssId(1) returns only rssId = 1', () async {
    final list = await repository.getArticlesByRssId(1);
    for (var a in list) {
      expect(a.rssId, 1);
    }
  });
}
