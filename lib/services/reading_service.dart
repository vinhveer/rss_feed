import 'package:flutter_tts/flutter_tts.dart';
import '../repository/article_content_repository.dart';

class NewsReadingService {
  final ArticleContentRepository _repository = ArticleContentRepository();
  final FlutterTts _flutterTts = FlutterTts();

  Function()? onStart;
  Function()? onComplete;
  Function()? onStop;

  // State for skipping/backward
  List<String> _sentences = [];
  int _currentIndex = 0;
  String _currentCleanedText = '';
  double _speechRate = 0.5;

  NewsReadingService() {
    _flutterTts.setStartHandler(() => onStart?.call());
    _flutterTts.setCompletionHandler(() async {
      // Move to next sentence if any
      if (_currentIndex < _sentences.length - 1) {
        _currentIndex++;
        await _speakCurrent();
      } else {
        onComplete?.call();
      }
    });
    _flutterTts.setCancelHandler(() => onStop?.call());
  }

  /// Chuyển đổi định dạng ngày sang tiếng Việt
  String _formatVietnameseDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return 'ngày ${date.day} tháng ${date.month} năm ${date.year}';
    } catch (_) {
      return 'Không rõ';
    }
  }

  /// Xoá ảnh (Markdown hoặc link ảnh trực tiếp)
  String _removeImages(String input) {
    String cleaned = input.replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), ''); // ![alt](url)
    cleaned = cleaned.replaceAll(RegExp(r'http\S+\.(jpg|jpeg|png|gif)'), ''); // link ảnh
    return cleaned;
  }

  /// Chuyển markdown link [text](url) -> text
  String _removeMarkdownLinks(String input) {
    return input.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\([^)]+\)'),
          (match) => match.group(1) ?? '',
    );
  }

  /// Làm sạch văn bản: bỏ ký tự đặc biệt thừa, gom khoảng trắng
  String _cleanText(String input) {
    return input
        .replaceAll(RegExp(r'[^\w\sÀ-ỹà-ỹ.,!?]'), '') // giữ chữ, số, khoảng trắng, dấu câu
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Đọc bài báo từ URL
  Future<void> readArticle(String articleUrl) async {
    final content = await _repository.fetchArticleContent(articleUrl);
    if (content == null) return;

    final String title = content['title'] ?? '';
    final String text = content['text'] ?? '';
    final String author = content['author'] ?? '';
    final String pubDate = content['pubDate'] ?? '';

    final String dateFormatted = pubDate.isNotEmpty
        ? _formatVietnameseDate(pubDate)
        : 'Không rõ';

    final String fullText = '''
$title.
Tác giả: ${author.isNotEmpty ? author : "Không rõ"}.
Ngày đăng: $dateFormatted.
$text
''';

    // Làm sạch nội dung: bỏ ảnh, bỏ link markdown, bỏ ký tự đặc biệt
    String cleaned = _removeImages(fullText);
    cleaned = _removeMarkdownLinks(cleaned);
    cleaned = _cleanText(cleaned);

    _currentCleanedText = cleaned;
    _sentences = _splitSentences(cleaned);
    _currentIndex = 0;

    await _flutterTts.setLanguage("vi-VN");
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    await _speakCurrent();
  }

  /// Đọc câu hiện tại
  Future<void> _speakCurrent() async {
    if (_currentIndex >= 0 && _currentIndex < _sentences.length) {
      await _flutterTts.speak(_sentences[_currentIndex]);
    }
  }

  /// Skip đến câu tiếp theo
  Future<void> skipForward() async {
    if (_currentIndex < _sentences.length - 1) {
      _currentIndex++;
      await _flutterTts.stop();
      await _speakCurrent();
    }
  }

  /// Quay lại câu trước
  Future<void> skipBackward() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await _flutterTts.stop();
      await _speakCurrent();
    }
  }

  /// Đặt tốc độ đọc (0.0 - 1.0)
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.0, 1.0);
    await _flutterTts.setSpeechRate(_speechRate);
    // Nếu đang đọc, đọc lại câu hiện tại với tốc độ mới
    if (_sentences.isNotEmpty && _currentIndex >= 0 && _currentIndex < _sentences.length) {
      await _flutterTts.stop();
      await _speakCurrent();
    }
  }

  /// Tách văn bản thành các câu
  List<String> _splitSentences(String text) {
    // Chia theo dấu chấm, chấm hỏi, chấm than, giữ dấu câu
    final regex = RegExp(r'[^.!?]+[.!?]');
    final matches = regex.allMatches(text);
    return matches.map((m) => m.group(0)!.trim()).where((s) => s.isNotEmpty).toList();
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}