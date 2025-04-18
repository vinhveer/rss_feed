class Article{
  String title, link, pudDate;
  String? description, imageUrl;

  Article({
    required this.title,
    required this.link,
    required this.pudDate,
    this.description,
    this.imageUrl,
  });
}