import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/movie_model.dart';

class Movie {
  final String id;
  final String title;
  final int year;
  final String posterUrl;
  final double vote;
  final String overview;

  Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.posterUrl,
    required this.vote,
    required this.overview,
  });

  /// Construit un Movie à partir du JSON de l’API IMDb8 /auto-complete
  ///
  /// Exemple de JSON:
  /// {
  ///   "id": "tt0944947",
  ///   "l": "Game of Thrones",
  ///   "y": 2011,
  ///   "i": { "imageUrl": "https://....jpg", "height": 824, "width": 550 },
  ///   "s": "Emilia Clarke, Peter Dinklage",
  ///   ...
  /// }
  factory Movie.fromApi(Map<String, dynamic> data) {
    final id = (data['id'] ?? '').toString();
    final title = (data['l'] ?? 'No title') as String;

    final yearDynamic = data['y'];
    int year = 0;
    if (yearDynamic is int) {
      year = yearDynamic;
    } else if (yearDynamic is String) {
      year = int.tryParse(yearDynamic) ?? 0;
    }

    String posterUrl = '';
    if (data['i'] is Map<String, dynamic>) {
      final img = data['i'] as Map<String, dynamic>;
      posterUrl = (img['imageUrl'] ?? '') as String;
    }

    // L’endpoint auto-complete ne renvoie pas de vraie note → on met 0
    const double vote = 0.0;

    // On peut mettre le cast/description dans overview si on veut
    final overview = (data['s'] ?? '') as String;

    // Si jamais id est vide, on le fabrique (titre+année) pour Firestore
    final safeId = id.isNotEmpty
        ? id
        : '${title.replaceAll(' ', '_')}_$year';

    return Movie(
      id: safeId,
      title: title,
      year: year,
      posterUrl: posterUrl,
      vote: vote,
      overview: overview,
    );
  }

  /// Ce qu’on enregistre dans Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'year': year,
      'posterUrl': posterUrl,
      'vote': vote,
      'overview': overview,
      'isFromApi': true,
      'addedAt': DateTime.now(),
    };
  }
}
