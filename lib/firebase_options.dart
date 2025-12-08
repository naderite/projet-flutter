// GENERATED CODE - FirebaseOptions for your "movie-709e9" project

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // 🔹 Config Web
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: "AIzaSyBg0o13J6ie3a3fOUUeT3jFcCm1bxcBSeo",
        authDomain: "movie-709e9.firebaseapp.com",
        projectId: "movie-709e9",
        storageBucket: "movie-709e9.firebasestorage.app",
        messagingSenderId: "4521177600",
        appId: "1:4521177600:web:81347a545ab2e994cd1ee5",
        measurementId: "G-LMSZW3MPRJ",
      );
    }

    // 🔹 Config pour les plateformes natives
    switch (defaultTargetPlatform) {
    // Android + Windows → même config (ça t’évite l’erreur Unsupported)
      case TargetPlatform.android:
      case TargetPlatform.windows:
        return const FirebaseOptions(
          apiKey: "AIzaSyBg0o13J6ie3a3fOUUeT3jFcCm1bxcBSeo",
          projectId: "movie-709e9",
          storageBucket: "movie-709e9.firebasestorage.app",
          messagingSenderId: "4521177600",
          appId: "1:4521177600:web:81347a545ab2e994cd1ee5",
        );

    // iOS / macOS (tu peux laisser comme ça, tu ne testes pas dessus)
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return const FirebaseOptions(
          apiKey: '<YOUR-IOS-API-KEY>',
          appId: '<IOS-APP-ID>',
          messagingSenderId: '<SENDER-ID>',
          projectId: 'movie-709e9',
          storageBucket: 'movie-709e9.appspot.com',
          iosBundleId: '<BUNDLE-ID>',
          iosClientId: '<IOS-CLIENT-ID>',
        );

    // Autres plateformes non gérées
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}
