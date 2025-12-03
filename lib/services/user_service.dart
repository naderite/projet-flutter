import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final users = FirebaseFirestore.instance.collection('users');

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await users.doc(uid).get();
    return doc.data();
  }
}
