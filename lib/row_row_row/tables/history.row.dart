// Generated by row_row_row tool
// Auto-generated file. Do not modify.
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryRow {
  static const table = 'history';

  static const field = (
    historyId: 'history_id',
    userId: 'user_id',
    articleId: 'article_id',
    numberOfArticleView: 'number_of_article_view',
    maximumReadTime: 'maximum_read_time',
    averageReadTime: 'average_read_time',
    percentageScrolled: 'percentage_scrolled',
  );

  final int historyId;
  final String userId;
  final int? articleId;
  final int? numberOfArticleView;
  final dynamic maximumReadTime;
  final dynamic averageReadTime;
  final int? percentageScrolled;

  const HistoryRow({
    required this.historyId,
    required this.userId,
    this.articleId,
    this.numberOfArticleView,
    this.maximumReadTime,
    this.averageReadTime,
    this.percentageScrolled,
  });

  factory HistoryRow.fromJson(Map<String, dynamic> json) {
    return HistoryRow(
      historyId: (json[field.historyId] as num).toInt(),
      userId: json[field.userId] as String,
      articleId:
          json[field.articleId] == null
              ? null
              : (json[field.articleId] as num?)?.toInt(),
      numberOfArticleView:
          json[field.numberOfArticleView] == null
              ? null
              : (json[field.numberOfArticleView] as num?)?.toInt(),
      maximumReadTime: json[field.maximumReadTime],
      averageReadTime: json[field.averageReadTime],
      percentageScrolled:
          json[field.percentageScrolled] == null
              ? null
              : (json[field.percentageScrolled] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      field.historyId: historyId,
      field.userId: userId,
      field.articleId: articleId,
      field.numberOfArticleView: numberOfArticleView,
      field.maximumReadTime: maximumReadTime,
      field.averageReadTime: averageReadTime,
      field.percentageScrolled: percentageScrolled,
    };
  }

  HistoryRow copyWith({
    int? historyId,
    String? userId,
    int? articleId,
    int? numberOfArticleView,
    dynamic maximumReadTime,
    dynamic averageReadTime,
    int? percentageScrolled,
  }) {
    return HistoryRow(
      historyId: historyId ?? this.historyId,
      userId: userId ?? this.userId,
      articleId: articleId ?? this.articleId,
      numberOfArticleView: numberOfArticleView ?? this.numberOfArticleView,
      maximumReadTime: maximumReadTime ?? this.maximumReadTime,
      averageReadTime: averageReadTime ?? this.averageReadTime,
      percentageScrolled: percentageScrolled ?? this.percentageScrolled,
    );
  }

  /// Creates a new row in the database.
  ///
  /// Only non-null fields will be included in the insert payload.
  /// Primary keys and auto-generated fields can be set manually or left null for database defaults.
  /// Returns the created row with any auto-generated values.
  ///
  /// Requires [supabase_flutter] package to be installed and initialized.
  /// Fetches a single row from the database by its primary key.
  ///
  /// Returns the row if found, or throws an error if not found.
  ///
  /// Requires [supabase_flutter] package to be installed and initialized.
  static Future<HistoryRow> create({
    int? historyId,
    String? userId,
    int? articleId,
    int? numberOfArticleView,
    dynamic maximumReadTime,
    dynamic averageReadTime,
    int? percentageScrolled,
  }) async {
    // Build the insert payload with only non-null fields using collection if
    final Map<String, dynamic> insertPayload = {
      if (historyId != null) field.historyId: historyId,
      if (userId != null) field.userId: userId,
      if (articleId != null) field.articleId: articleId,
      if (numberOfArticleView != null)
        field.numberOfArticleView: numberOfArticleView,
      if (maximumReadTime != null) field.maximumReadTime: maximumReadTime,
      if (averageReadTime != null) field.averageReadTime: averageReadTime,
      if (percentageScrolled != null)
        field.percentageScrolled: percentageScrolled,
    };

    final response =
        await Supabase.instance.client
            .from(table)
            .insert(insertPayload)
            .select()
            .single();
    return HistoryRow.fromJson(response);
  }

  /// Fetches a single row from the database by its primary key.
  ///
  /// Returns the row if found, or throws an error if not found.
  ///
  /// Requires [supabase_flutter] package to be installed and initialized.
  static Future<HistoryRow> getFromHistoryId(int historyId) async {
    final response =
        await Supabase.instance.client
            .from(table)
            .select()
            .eq(field.historyId, historyId)
            .single();
    return HistoryRow.fromJson(response);
  }
}
