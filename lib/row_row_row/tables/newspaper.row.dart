// Generated by row_row_row tool
// Auto-generated file. Do not modify.
import 'package:supabase_flutter/supabase_flutter.dart';
class NewspaperRow {
  static const table = 'newspaper';

  static const field = (
    newspaperId: 'newspaper_id',
    newspaperName: 'newspaper_name',
    newspaperImage: 'newspaper_image',
    isVn: 'is_vn',
  );

  final int newspaperId;
  final String newspaperName;
  final String? newspaperImage;
  final bool? isVn;

  const NewspaperRow({
    required this.newspaperId,
    required this.newspaperName,
    this.newspaperImage,
    this.isVn,
  });

  factory NewspaperRow.fromJson(Map<String, dynamic> json) {
    return NewspaperRow(
      newspaperId: (json[field.newspaperId] as num).toInt(),
      newspaperName: json[field.newspaperName] as String,
      newspaperImage: json[field.newspaperImage],
      isVn: json[field.isVn],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      field.newspaperId: newspaperId,
      field.newspaperName: newspaperName,
      field.newspaperImage: newspaperImage,
      field.isVn: isVn,
    };
  }

  NewspaperRow copyWith({
    int? newspaperId,
    String? newspaperName,
    String? newspaperImage,
    bool? isVn,
  }) {
    return NewspaperRow(
      newspaperId: newspaperId ?? this.newspaperId,
      newspaperName: newspaperName ?? this.newspaperName,
      newspaperImage: newspaperImage ?? this.newspaperImage,
      isVn: isVn ?? this.isVn,
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
  static Future<NewspaperRow> create({
    int? newspaperId,
    String? newspaperName,
    String? newspaperImage,
    bool? isVn,
  }) async {
    // Build the insert payload with only non-null fields using collection if
    final Map<String, dynamic> insertPayload = {
      if (newspaperId != null) field.newspaperId: newspaperId,
      if (newspaperName != null) field.newspaperName: newspaperName,
      if (newspaperImage != null) field.newspaperImage: newspaperImage,
      if (isVn != null) field.isVn: isVn,
    };

    final response = await Supabase.instance.client
        .from(table)
        .insert(insertPayload)
        .select()
        .single();
    return NewspaperRow.fromJson(response);
  }

  /// Fetches a single row from the database by its primary key.
  /// 
  /// Returns the row if found, or throws an error if not found.
  /// 
  /// Requires [supabase_flutter] package to be installed and initialized.
  static Future<NewspaperRow> getFromNewspaperId(int newspaperId) async {
    final response = await Supabase.instance.client
        .from(table)
        .select()
        .eq(field.newspaperId, newspaperId)
        .single();
    return NewspaperRow.fromJson(response);
  }
}
