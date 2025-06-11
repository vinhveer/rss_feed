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
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                uri.toString(),
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2.5,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Đang tải...',
                            style: TextStyle(
                              fontSize: fontSize - 2,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported_outlined,
                        size: 40,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Không thể tải ảnh',
                        style: TextStyle(
                          fontSize: fontSize - 2,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
          // Paragraph styling
          p: TextStyle(
            fontSize: fontSize,
            height: 1.6,
            color: theme.colorScheme.onSurface,
            letterSpacing: 0.2,
          ),
          
          // Heading styles với spacing hẹp hơn
          h1: TextStyle(
            fontSize: fontSize + 8,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.primary,
            height: 1.3,
            letterSpacing: -0.5,
          ),
          h2: TextStyle(
            fontSize: fontSize + 6,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
            height: 1.4,
            letterSpacing: -0.3,
          ),
          h3: TextStyle(
            fontSize: fontSize + 4,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
            height: 1.4,
            letterSpacing: -0.2,
          ),
          h4: TextStyle(
            fontSize: fontSize + 2,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
            height: 1.4,
          ),
          h5: TextStyle(
            fontSize: fontSize + 1,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
            height: 1.4,
          ),
          h6: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
          
          // Modern blockquote
          blockquote: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: fontSize,
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
            letterSpacing: 0.1,
          ),
          blockquotePadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          blockquoteDecoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(
                color: theme.colorScheme.primary,
                width: 3,
              ),
            ),
          ),
          
          // Modern code styling
          code: TextStyle(
            fontSize: fontSize - 1,
            fontFamily: 'SF Mono',
            color: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.15),
            letterSpacing: 0,
          ),
          codeblockPadding: const EdgeInsets.all(16),
          codeblockDecoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          
          // Subtle horizontal rule
          horizontalRuleDecoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          
          // List styling
          listBullet: TextStyle(
            fontSize: fontSize,
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
          
          // Link styling
          a: TextStyle(
            fontSize: fontSize,
            color: theme.colorScheme.primary,
            decoration: TextDecoration.none,
            fontWeight: FontWeight.w500,
          ),
          
          // Strong/Bold text
          strong: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
          
          // Emphasis/Italic text
          em: TextStyle(
            fontSize: fontSize,
            fontStyle: FontStyle.italic,
            color: theme.colorScheme.onSurface,
          ),
          
          // Table styling
          tableHead: TextStyle(
            fontSize: fontSize - 1,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          tableBody: TextStyle(
            fontSize: fontSize - 1,
            color: theme.colorScheme.onSurface,
          ),
          tableBorder: TableBorder.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
            borderRadius: BorderRadius.circular(8),
          ),
          tableHeadAlign: TextAlign.left,
          tableCellsPadding: const EdgeInsets.all(8),
        ),
      ),
    );
  }
}