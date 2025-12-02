import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Small authentication service that centralizes FirebaseAuth + Firestore
/// user document creation. Keeps the UI code thin and makes it easier to
/// test and reuse.
class AuthService {
  AuthService();

  /// Registers a new user with email/password, sets display name and
  /// creates a Firestore user document (if missing).
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    required int age,
  }) async {
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update the Auth profile's display name
    await cred.user?.updateDisplayName(displayName);

    // Ensure a user document exists in Firestore
    if (cred.user != null) {
      await _createOrUpdateUserDoc(
        cred.user!,
        displayName: displayName,
        age: age,
      );
    }

    return cred;
  }

  /// Signs in using Google and creates a Firestore user document when the
  /// user is new (or merges fields if the doc exists).
  Future<UserCredential> signInWithGoogle() async {
    // On web, use the Firebase popup/redirect flow. On mobile, use the
    // google_sign_in plugin to obtain tokens and sign in with a credential.
    late final UserCredential userCred;
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      userCred = await FirebaseAuth.instance.signInWithPopup(provider);
    } else {
      // Trigger the Google Sign-In flow on mobile
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw StateError('Google sign-in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      userCred = await FirebaseAuth.instance.signInWithCredential(credential);
    }

    // Create or merge user document in Firestore
    if (userCred.user != null) {
      await _createOrUpdateUserDoc(userCred.user!);
    }

    return userCred;
  }

  Future<void> _createOrUpdateUserDoc(
    User user, {
    String? displayName,
    int? age,
  }) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    final snapshot = await docRef.get();
    final data = <String, dynamic>{
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName ?? displayName,
      'photoURL': user.photoURL,
    };

    if (age != null) {
      data['age'] = age;
    }

    if (!snapshot.exists) {
      // New document: set with createdAt and default role
      await docRef.set({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'user',
      });
    } else {
      // Merge new fields into existing document
      await docRef.set(data, SetOptions(merge: true));
    }
  }

  /// Returns the role stored in the user's Firestore document, or null if
  /// not available. Defaults to 'user' for new accounts created by this service.
  Future<String?> getUserRole(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    final role = data['role'];
    return role is String ? role : null;
  }

  /// Convenience which queries the currently signed-in user's role.
  Future<String?> getCurrentUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return getUserRole(user.uid);
  }

  /// Set or update a user's role. Only call this from trusted contexts
  /// (server/admin). This method performs a client-side write and should be
  /// protected with backend security rules in production.
  Future<void> setUserRole(String uid, String role) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    await docRef.set({'role': role}, SetOptions(merge: true));
  }

  /// Check if the current user is in the given role.
  Future<bool> currentUserIsInRole(String role) async {
    final r = await getCurrentUserRole();
    return r == role;
  }

  /// Sign out the currently signed-in user (and sign out Google if used).
  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {
      // ignore errors from GoogleSignIn signOut if not applicable
    }
    await FirebaseAuth.instance.signOut();
  }

  /// Returns the `age` field from the current user's Firestore document,
  /// or null if missing.
  Future<int?> getCurrentUserAge() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    final a = data['age'];
    if (a == null) return null;
    if (a is int) return a;
    if (a is num) return a.toInt();
    return null;
  }

  /// Sets or updates the age field for the currently signed-in user.
  Future<void> setUserAge(int age) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('No signed-in user');
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await docRef.set({'age': age}, SetOptions(merge: true));
  }
}
