import 'package:translator/translator.dart';

class TranslateService {
  final GoogleTranslator _translator = GoogleTranslator();

  Future<String> translate(String text, String fromLang, String toLang) async {
    try {
      final lines = text.split('\n');

      final translatedLines = await Future.wait(lines.map((line) async {
        final trimmed = line.trim();

        // 1. Bỏ qua ảnh markdown
        if (trimmed.startsWith('![')) return line;

        // 2. Giữ dòng trống
        if (trimmed.isEmpty) return line;

        // 3. Bỏ qua dòng toàn in hoa (<= 5 từ)
        final noPunctuation = trimmed.replaceAll(RegExp(r'[^\w\s]'), '');
        final words = noPunctuation.split(' ');
        final isUpperCase = words.every((w) => w.toUpperCase() == w);
        if (isUpperCase && words.length <= 5) return line;

        // 4. Gỡ định dạng markdown [text](link) => text
        final linkRegex = RegExp(r'\[(.*?)\]\(.*?\)');
        String processedLine = line.replaceAllMapped(linkRegex, (match) => match.group(1)!);

        // 5. Gỡ các ký tự định dạng *, **, ***
        processedLine = processedLine.replaceAll(RegExp(r'\*{1,3}'), '');

        // 6. Dịch
        final translated = await _translator.translate(processedLine, from: fromLang, to: toLang);
        return translated.text;
      }));

      return translatedLines.join('\n');
    } catch (e) {
      return text;
    }
  }
}
