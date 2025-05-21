import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../repository/article_content_repository.dart';

class ReadingController extends GetxController {
  final ArticleContentRepository _repository = ArticleContentRepository();
  final FlutterTts _flutterTts = FlutterTts();

  final bool isVn;
  ReadingController({required this.isVn});

  // Rx variables for UI binding
  final RxBool isReading = false.obs;
  final RxBool isCompleted = false.obs;
  final RxInt currentIndex = 0.obs;
  final RxDouble speechRate = 0.5.obs;

  List<String> _sentences = [];
  String _currentCleanedText = '';
  String? _currentUrl;

  @override
  void onInit() {
    super.onInit();
    _flutterTts.setStartHandler(() => isReading.value = true);
    _flutterTts.setCompletionHandler(() async {
      if (currentIndex.value < _sentences.length - 1) {
        currentIndex.value++;
        await _speakCurrent();
      } else {
        isCompleted.value = true;
        isReading.value = false;
      }
    });
    _flutterTts.setCancelHandler(() {
      isReading.value = false;
    });
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
    String cleaned = input.replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), '');
    cleaned = cleaned.replaceAll(RegExp(r'http\\S+\\.(jpg|jpeg|png|gif)'), '');
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
        .replaceAll(RegExp(r'[^\w\sÀ-ỹà-ỹ.,!?]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Tách văn bản thành các câu
  List<String> _splitSentences(String text) {
    final regex = RegExp(r'[^.!?]+[.!?]');
    final matches = regex.allMatches(text);
    return matches.map((m) => m.group(0)!.trim()).where((s) => s.isNotEmpty).toList();
  }

  /// Đọc bài báo từ URL
  Future<void> readArticle(String articleUrl,  {required bool isVn}) async {
    isCompleted.value = false;
    isReading.value = false;
    _currentUrl = articleUrl;

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

    String cleaned = _removeImages(fullText);
    cleaned = _removeMarkdownLinks(cleaned);
    cleaned = _cleanText(cleaned);

    _currentCleanedText = cleaned;
    _sentences = _splitSentences(cleaned);
    currentIndex.value = 0;

    await _flutterTts.setLanguage(isVn ? "vi-VN" : "en-US");
    await _flutterTts.setSpeechRate(speechRate.value);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    await _speakCurrent();
  }

  Future<void> _speakCurrent() async {
    if (currentIndex.value >= 0 && currentIndex.value < _sentences.length) {
      await _flutterTts.speak(_sentences[currentIndex.value]);
      isReading.value = true;
    }
  }

  /// Tiếp câu tiếp theo
  Future<void> skipForward() async {
    if (currentIndex.value < _sentences.length - 1) {
      currentIndex.value++;
      await _flutterTts.stop();
      await _speakCurrent();
    }
  }

  /// Quay lại câu trước
  Future<void> skipBackward() async {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      await _flutterTts.stop();
      await _speakCurrent();
    }
  }

  /// Đặt tốc độ đọc (0.0-1.0)
  Future<void> setSpeechRate(double rate) async {
    speechRate.value = rate.clamp(0.0, 1.0);
    await _flutterTts.setSpeechRate(speechRate.value);
    // Nếu đang đọc, đọc lại câu hiện tại với tốc độ mới
    if (_sentences.isNotEmpty &&
        currentIndex.value >= 0 &&
        currentIndex.value < _sentences.length) {
      await _flutterTts.stop();
      await _speakCurrent();
    }
  }

  /// Tạm dừng hoặc phát lại
  Future<void> toggleReading() async {
    if (isReading.value) {
      await _flutterTts.pause();
      isReading.value = false;
    } else {
      await _speakCurrent();
    }
  }

  /// Dừng đọc hoàn toàn
  Future<void> stop() async {
    await _flutterTts.stop();
    isReading.value = false;
  }
}