import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie.dart';

class FavoriteMovie {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<Map<String, List<String>>> getAllUsersFavorites() {
    return FirebaseFirestore.instance.collection("users").snapshots().asyncMap((
      snapshot,
    ) async {
      Map<String, List<String>> result = {};

      for (var doc in snapshot.docs) {
        final favSnapshot = await doc.reference.collection("favorites").get();
        final favIds = favSnapshot.docs.map((d) => d.id).toList();

        result[doc.id] = favIds;
      }

      return result;
    });
  }

  Stream<List<Movie>> getFavoriteMovies() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return _firestore
        .collection("users")
        .doc(uid)
        .collection("favorites")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return Movie(
              id: doc.id,
              title: data['title'] ?? '',
              imageUrl: data['image'] ?? '',
              year: (data['year'] ?? 0).toDouble(),
              category: data['category'] ?? '',
            );
          }).toList(),
        );
  }
}
