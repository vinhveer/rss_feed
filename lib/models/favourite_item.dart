class FavouriteItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final DateTime savedDate;
  bool isSelected;

  FavouriteItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.savedDate,
    this.isSelected = false,
  });
}