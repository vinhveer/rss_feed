class ArticleFavouriteException implements Exception {
  final String message;
  const ArticleFavouriteException(this.message);
  @override
  String toString() => 'ArticleFavouriteException: $message';
}