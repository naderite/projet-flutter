import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

/// Lightweight IMDb suggestion-based service.
/// NOTE: This uses an unofficial public endpoint and may break.
class MovieApiService {
  MovieApiService._();

  /// Search suggestions endpoint
  static Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];
    final q = query.trim();
    final first = q[0].toLowerCase();
    final url = Uri.parse('https://v2.sg.media-imdb.com/suggestion/$first/${Uri.encodeComponent(q)}.json');

    try {
      final res = await http.get(url);
      if (res.statusCode != 200) return [];
      final Map<String, dynamic> json = jsonDecode(res.body) as Map<String, dynamic>;
      final list = <Movie>[];
      if (json['d'] is List) {
        for (final item in json['d']) {
          if (item is Map<String, dynamic>) {
            try {
              list.add(Movie.fromApi(item));
            } catch (_) {
              // ignore malformed
            }
          }
        }
      }
      return list;
    } catch (e) {
      return [];
    }
  }

  /// Quick heuristic for a "popular" list — performs a broad search.
  static Future<List<Movie>> getPopularMovies() async {
    // Using a common token to get many results; adjust as needed.
    return await searchMovies('star');
  }
}
