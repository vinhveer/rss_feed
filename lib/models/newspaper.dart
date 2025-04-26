class Newspaper {
  final int id;
  final String name;

  Newspaper({
    required this.id,
    required this.name,
  });

  factory Newspaper.fromJson(Map<String, dynamic> json) {
    return Newspaper(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}