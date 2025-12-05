import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final users = FirebaseFirestore.instance.collection('users');

  String currentUserUid() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  Future<Map<String, dynamic>?> getUserDataById(String userId) async {
    final doc = await users.doc(userId).get();
    return doc.data();
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await users.doc(uid).get();
    return doc.data();
  }
}
