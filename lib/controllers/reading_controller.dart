import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../repository/extract_content_repository.dart';

class ReadingController extends GetxController {
  final ArticleContentRepository _repository = ArticleContentRepository();
  final FlutterTts _flutterTts = FlutterTts();

  final bool isVn;
  ReadingController({required this.isVn});

  // Rx variables for UI binding
  final RxBool isReading = false.obs;
  final RxBool isPlaying = false.obs; // Thêm để phân biệt pause/play
  final RxBool isCompleted = false.obs;
  final RxInt currentIndex = 0.obs;
  final RxDouble speechRate = 1.0.obs; // Đổi default thành 1.0

  List<String> _sentences = [];
  String _currentCleanedText = '';
  String? _currentUrl;
  bool _isPaused = false; // Track pause state

  @override
  void onInit() {
    super.onInit();
    _flutterTts.setStartHandler(() {
      isReading.value = true;
      isPlaying.value = true;
      _isPaused = false;
    });

    _flutterTts.setCompletionHandler(() async {
      if (currentIndex.value < _sentences.length - 1) {
        currentIndex.value++;
        await _speakCurrent();
      } else {
        isCompleted.value = true;
        isReading.value = false;
        isPlaying.value = false;
        _isPaused = false;
      }
    });

    _flutterTts.setCancelHandler(() {
      isPlaying.value = false;
      if (!_isPaused) {
        isReading.value = false;
      }
    });

    _flutterTts.setPauseHandler(() {
      isPlaying.value = false;
      _isPaused = true;
    });

    _flutterTts.setContinueHandler(() {
      isPlaying.value = true;
      _isPaused = false;
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
    cleaned = cleaned.replaceAll(RegExp(r'https?://\S+\.(jpg|jpeg|png|gif|webp)', caseSensitive: false), '');
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
    // Cải thiện regex để tách câu tốt hơn
    final regex = RegExp(r'[^.!?]*[.!?]+(?=\s|$)');
    final matches = regex.allMatches(text);
    List<String> sentences = matches
        .map((m) => m.group(0)!.trim())
        .where((s) => s.isNotEmpty && s.length > 3)
        .toList();

    // Nếu không tách được câu, chia theo dấu xuống dòng
    if (sentences.isEmpty) {
      sentences = text.split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty && s.length > 3)
          .toList();
    }

    return sentences;
  }

  /// Đọc bài báo từ URL
  Future<void> readArticle(String articleUrl, {required bool isVn}) async {
    try {
      isCompleted.value = false;
      isReading.value = false;
      isPlaying.value = false;
      _isPaused = false;
      _currentUrl = articleUrl;

      final content = await _repository.fetchArticleContent(articleUrl);
      if (content == null) return;

      final String title = content['title'] ?? '';
      final String text = content['text'] ?? '';
      final String pubDate = content['pubDate'] ?? '';

      final String dateFormatted = pubDate.isNotEmpty
          ? _formatVietnameseDate(pubDate)
          : 'Không rõ';

      final String fullText = '''
        $title.
        Ngày đăng: $dateFormatted.
        $text
        ''';

      String cleaned = _removeImages(fullText);
      cleaned = _removeMarkdownLinks(cleaned);
      cleaned = _cleanText(cleaned);

      _currentCleanedText = cleaned;
      _sentences = _splitSentences(cleaned);
      currentIndex.value = 0;

      await _setupTTS(isVn);
      await _speakCurrent();
    } catch (e) {
      print('Error reading article: $e');
      isReading.value = false;
      isPlaying.value = false;
    }
  }

  Future<void> _setupTTS(bool isVn) async {
    await _flutterTts.setLanguage(isVn ? "vi-VN" : "en-US");
    await _flutterTts.setSpeechRate(speechRate.value);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speakCurrent() async {
    if (currentIndex.value >= 0 && currentIndex.value < _sentences.length) {
      await _flutterTts.speak(_sentences[currentIndex.value]);
    }
  }

  /// Tiến 10 giây (hoặc câu tiếp theo)
  Future<void> skipForward() async {
    if (currentIndex.value < _sentences.length - 1) {
      currentIndex.value++;
      await _flutterTts.stop();
      if (isReading.value) {
        await _speakCurrent();
      }
    }
  }

  /// Lùi 10 giây (hoặc câu trước)
  Future<void> skipBackward() async {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      await _flutterTts.stop();
      if (isReading.value) {
        await _speakCurrent();
      }
    }
  }

  /// Đặt tốc độ đọc (0.5-2.0)
  Future<void> setSpeechRate(double rate) async {
    speechRate.value = rate.clamp(0.5, 2.0);
    await _flutterTts.setSpeechRate(speechRate.value);

    // Nếu đang đọc, áp dụng tốc độ mới ngay lập tức
    if (isPlaying.value && _sentences.isNotEmpty &&
        currentIndex.value >= 0 &&
        currentIndex.value < _sentences.length) {
      await _flutterTts.stop();
      await _speakCurrent();
    }
  }

  /// Tạm dừng hoặc tiếp tục đọc
  Future<void> toggleReading() async {
    if (isPlaying.value) {
      // Đang phát -> tạm dừng
      await _flutterTts.pause();
    } else if (_isPaused) {
      // Đang tạm dừng -> tiếp tục
      await _flutterTts.speak(_sentences[currentIndex.value]);
    } else {
      // Chưa bắt đầu hoặc đã dừng -> bắt đầu đọc
      await _speakCurrent();
    }
  }

  /// Dừng đọc hoàn toàn
  Future<void> stop() async {
    await _flutterTts.stop();
    isReading.value = false;
    isPlaying.value = false;
    _isPaused = false;
    currentIndex.value = 0;
  }

  @override
  void onClose() {
    _flutterTts.stop();
    super.onClose();
  }
}