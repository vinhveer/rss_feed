import 'package:flutter/material.dart';

class CategoryUtils {
  static IconData getIconForCategory(String category) {
    switch (category) {
      case 'Thể thao':
        return Icons.sports_soccer;
      case 'Giải trí':
        return Icons.movie;
      case 'Khoa học':
        return Icons.science;
      case 'Âm nhạc':
        return Icons.music_note;
      case 'Trò chơi':
        return Icons.games;
      case 'Tin tức':
        return Icons.newspaper;
      case 'Công nghệ':
        return Icons.computer;
      case 'Nóng':
        return Icons.local_fire_department;
      default:
        return Icons.article;
    }
  }

  static Color getCategoryColor(String category, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (category) {
      case 'Thể thao':
        return isDark ? Colors.blue[300]! : Colors.blue;
      case 'Giải trí':
        return isDark ? Colors.purple[300]! : Colors.purple;
      case 'Khoa học':
        return isDark ? Colors.green[300]! : Colors.green;
      case 'Âm nhạc':
        return isDark ? Colors.pink[300]! : Colors.pink;
      case 'Trò chơi':
        return isDark ? Colors.amber[300]! : Colors.amber;
      case 'Tin tức':
        return isDark ? Colors.brown[300]! : Colors.brown;
      case 'Công nghệ':
        return isDark ? Colors.indigo[300]! : Colors.indigo;
      case 'Nóng':
        return isDark ? Colors.deepOrange[300]! : Colors.deepOrange;
      default:
        return isDark ? Colors.blueGrey[300]! : Colors.blueGrey;
    }
  }

  static Color getCategoryBackgroundColor(String category, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return getCategoryColor(category, context).withAlpha(70);
    } else {
      return getCategoryColor(category, context).withAlpha(30);
    }
  }
}