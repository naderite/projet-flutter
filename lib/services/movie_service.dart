import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';

class MovieService {
  final _movies = FirebaseFirestore.instance.collection('movies');

  Stream<List<Movie>> getMovies() {
    return _movies.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Movie.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }
}
