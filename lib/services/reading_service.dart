import 'package:flutter_tts/flutter_tts.dart';
import '../repository/article_content_repository.dart';

class NewsReadingService {
  final ArticleContentRepository _repository = ArticleContentRepository();
  final FlutterTts _flutterTts = FlutterTts();

  Function()? onStart;
  Function()? onComplete;
  Function()? onStop;

  List<String> _sentences = [];
  int _currentIndex = 0;
  String _currentCleanedText = '';
  double _speechRate = 0.5;

  NewsReadingService() {
    _flutterTts.setStartHandler(() => onStart?.call());
    _flutterTts.setCompletionHandler(() async {
      if (_currentIndex < _sentences.length - 1) {
        _currentIndex++;
        await _speakCurrent();
      } else {
        onComplete?.call();
      }
    });
    _flutterTts.setCancelHandler(() => onStop?.call());
  }

  String _formatDate(String dateStr, bool isVn) {
    try {
      final date = DateTime.parse(dateStr);
      if (isVn) {
        return 'ngày ${date.day} tháng ${date.month} năm ${date.year}';
      } else {
        return '${date.month}/${date.day}/${date.year}';
      }
    } catch (_) {
      return isVn ? 'Không rõ' : 'Unknown';
    }
  }

  String _removeImages(String input) {
    String cleaned = input.replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), '');
    cleaned = cleaned.replaceAll(RegExp(r'http\S+\.(jpg|jpeg|png|gif)'), '');
    return cleaned;
  }

  String _removeMarkdownLinks(String input) {
    return input.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\([^)]+\)'),
          (match) => match.group(1) ?? '',
    );
  }

  String _cleanText(String input) {
    return input
        .replaceAll(RegExp(r'[^\w\sÀ-ỹà-ỹ.,!?]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> readArticle(String articleUrl, {required bool isVn}) async {
    final content = await _repository.fetchArticleContent(articleUrl);
    if (content == null) return;

    final String title = content['title'] ?? '';
    final String text = content['text'] ?? '';
    final String author = content['author'] ?? '';
    final String pubDate = content['pubDate'] ?? '';

    final String dateFormatted = _formatDate(pubDate, isVn);

    final String fullText = isVn
        ? '''
$title.
Tác giả: ${author.isNotEmpty ? author : "Không rõ"}.
Ngày đăng: $dateFormatted.
$text
'''
        : '''
$title.
Author: ${author.isNotEmpty ? author : "Unknown"}.
Published: $dateFormatted.
$text
''';

    String cleaned = _removeImages(fullText);
    cleaned = _removeMarkdownLinks(cleaned);
    cleaned = _cleanText(cleaned);

    _currentCleanedText = cleaned;
    _sentences = _splitSentences(cleaned);
    _currentIndex = 0;

    await _flutterTts.setLanguage(isVn ? "vi-VN" : "en-US");
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    await _speakCurrent();
  }

  Future<void> _speakCurrent() async {
    if (_currentIndex >= 0 && _currentIndex < _sentences.length) {
      await _flutterTts.speak(_sentences[_currentIndex]);
    }
  }

  Future<void> skipForward() async {
    if (_currentIndex < _sentences.length - 1) {
      _currentIndex++;
      await _flutterTts.stop();
      await _speakCurrent();
    }
  }

  Future<void> skipBackward() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await _flutterTts.stop();
      await _speakCurrent();
    }
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.0, 1.0);
    await _flutterTts.setSpeechRate(_speechRate);
    if (_sentences.isNotEmpty && _currentIndex >= 0 && _currentIndex < _sentences.length) {
      await _flutterTts.stop();
      await _speakCurrent();
    }
  }

  List<String> _splitSentences(String text) {
    final regex = RegExp(r'[^.!?]+[.!?]');
    final matches = regex.allMatches(text);
    return matches.map((m) => m.group(0)!.trim()).where((s) => s.isNotEmpty).toList();
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
