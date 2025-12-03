class Movie {
  final String title;
  final String category;
  final String imageUrl;
  final double year;

  Movie({
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.year,
  });

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      imageUrl: map['posterUrl'] ?? '',
      year: (map['year'] ?? 0).toDouble(),
    );
  }
}
