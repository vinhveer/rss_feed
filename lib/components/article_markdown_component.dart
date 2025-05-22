import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ArticleMarkdownComponent extends StatelessWidget {
  final String text;
  final double fontSize;
  final ThemeData theme;

  const ArticleMarkdownComponent({
    super.key,
    required this.text,
    required this.fontSize,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      textAlign: TextAlign.justify,
      child: MarkdownBody(
        data: text,
        selectable: true,
        imageBuilder: (uri, title, alt) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                uri.toString(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  width: double.infinity,
                  color: theme.colorScheme.inversePrimary,
                  child: Icon(
                    Icons.broken_image,
                    size: 60,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        },
        styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
          p: TextStyle(
            fontSize: fontSize,
            height: 1.7,
            color: theme.colorScheme.onSurface,
          ),
          h1: TextStyle(
            fontSize: fontSize + 10,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            height: 2,
          ),
          h2: TextStyle(
            fontSize: fontSize + 6,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
            height: 1.8,
          ),
          h3: TextStyle(
            fontSize: fontSize + 4,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
            height: 1.6,
          ),
          blockquote: TextStyle(
            fontStyle: FontStyle.italic,
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
          blockquotePadding: const EdgeInsets.all(12),
          blockquoteDecoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            border: Border(
              left: BorderSide(
                color: theme.colorScheme.primary,
                width: 4,
              ),
            ),
          ),
          code: TextStyle(
            fontSize: fontSize - 1,
            fontFamily: 'monospace',
            color: theme.colorScheme.onSurface,
            backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          codeblockPadding: const EdgeInsets.all(12),
          codeblockDecoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor,
                width: 1,
              ),
            ),
          ),
          listBullet: TextStyle(
            fontSize: fontSize,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}