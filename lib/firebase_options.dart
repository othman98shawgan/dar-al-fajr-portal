import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
/// Replace placeholder values with your Firebase project configuration
/// via `flutterfire configure` or environment variables.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return web;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCynLTXK8hLI5tY_vJlaZbwmK8VWD6qQaY',
    appId: '1:179915571219:web:003c289f98eb8d64f6ffe6',
    messagingSenderId: '179915571219',
    projectId: 'dar-al-fajr-portal',
    authDomain: 'dar-al-fajr-portal.firebaseapp.com',
    storageBucket: 'dar-al-fajr-portal.firebasestorage.app',
    measurementId: 'G-53PN1E5ZN4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAsNshJHVxk1WucgdzQlHkKVTwLe4twUDw',
    appId: '1:179915571219:android:fb121dd5b8197104f6ffe6',
    messagingSenderId: '179915571219',
    projectId: 'dar-al-fajr-portal',
    storageBucket: 'dar-al-fajr-portal.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA6l4IsWITY4jlrseqbcBrk_1NUYj4iIPU',
    appId: '1:179915571219:ios:53653db31eb1af72f6ffe6',
    messagingSenderId: '179915571219',
    projectId: 'dar-al-fajr-portal',
    storageBucket: 'dar-al-fajr-portal.firebasestorage.app',
    iosBundleId: 'com.example.darAlFajrPortal',
  );
  static const FirebaseOptions macos = ios;
  static const FirebaseOptions windows = web;
}
