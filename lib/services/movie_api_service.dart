import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/movie_model.dart';

class MovieApiService {
  // TA clé RapidAPI
  static const String _apiKey =
      'b3d3786989msh82000ea7d2f4015p1aa873jsn80c9762a2542';

  // Nouveau host IMDb8
  static const String _host = 'imdb8.p.rapidapi.com';

  /// Appelle l’endpoint /auto-complete?q=...
  static Future<List<Movie>> _fetchMovies(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final uri = Uri.https(
      _host,
      '/auto-complete',
      {'q': q},
    );

    final response = await http.get(
      uri,
      headers: {
        'X-Rapidapi-Key': _apiKey,
        'X-Rapidapi-Host': _host,
      },
    );

    if (response.statusCode != 200) {
      print('[MovieApiService] HTTP ${response.statusCode}: ${response.body}');
      return [];
    }

    final body = jsonDecode(response.body);

    // structure réelle : { "d": [ ... ] , "q": "...", "v": 1 }
    if (body is Map<String, dynamic> && body['d'] is List) {
      final list = body['d'] as List;
      return list
          .map<Movie>((e) => Movie.fromApi(e as Map<String, dynamic>))
          .toList();
    }

    print('[MovieApiService] Unexpected JSON: ${response.body}');
    return [];
  }

  /// 🔍 Recherche par texte
  static Future<List<Movie>> searchMovies(String query) async {
    return _fetchMovies(query);
  }

  /// ⭐ Liste initiale : on utilise une requête générique "game"
  /// (tu peux changer "game" par ce que tu veux : "spider", "harry", etc.)
  static Future<List<Movie>> getPopularMovies() async {
    return _fetchMovies('game');
  }
}
