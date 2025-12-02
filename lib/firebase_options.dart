// GENERATED CODE - placeholder FirebaseOptions
//
// This is a template `firebase_options.dart` file. Replace the placeholder
// strings below with the values from your Firebase project settings (or
// generate this file automatically with the FlutterFire CLI:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//)

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // Web configuration
      return FirebaseOptions(
        apiKey: "AIzaSyBg0o13J6ie3a3fOUUeT3jFcCm1bxcBSeo",
        authDomain: "movie-709e9.firebaseapp.com",
        projectId: "movie-709e9",
        storageBucket: "movie-709e9.firebasestorage.app",
        messagingSenderId: "4521177600",
        appId: "1:4521177600:web:81347a545ab2e994cd1ee5",
        measurementId: "G-LMSZW3MPRJ",
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Values extracted from android/app/google-services.json
        return FirebaseOptions(
          apiKey: "AIzaSyBtpZEcuWfMBULqc7fkuwlrWfPa6KkRhDk",
          appId: "1:4521177600:android:b84ecf9d3ba1b97fcd1ee5",
          messagingSenderId: "4521177600",
          projectId: "movie-709e9",
          storageBucket: "movie-709e9.firebasestorage.app",
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return FirebaseOptions(
          apiKey: '<YOUR-IOS-API-KEY>',
          appId: '<IOS-APP-ID>',
          messagingSenderId: '<SENDER-ID>',
          projectId: '<YOUR-PROJECT-ID>',
          storageBucket: '<YOUR-PROJECT>.appspot.com',
          iosBundleId: '<BUNDLE-ID>',
          iosClientId: '<IOS-CLIENT-ID>',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}
