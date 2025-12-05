class Movie {
  final String title;
  final String category;
  final String imageUrl;
  final double year;
  final String id;
  Movie({
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.year,
    required this.id,
  });

  factory Movie.fromMap(Map<String, dynamic> map, String documentId) {
    return Movie(
      id: documentId,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      imageUrl: map['posterUrl'] ?? '',
      year: (map['year'] ?? 0).toDouble(),
    );
  }
}
