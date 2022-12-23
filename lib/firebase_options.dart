// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC-3O_yomUVUfo7nQM_EmeJ1jUulTOylGg',
    appId: '1:925271095354:android:7ddce4ff7f99682f31dd03',
    messagingSenderId: '925271095354',
    projectId: 'cause-flutter-mvp',
    databaseURL: 'https://cause-flutter-mvp-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'cause-flutter-mvp.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCsjPFGC-sPi4bpIme8057SNMAIjBKSJbQ',
    appId: '1:925271095354:ios:9c9d90b197f971fa31dd03',
    messagingSenderId: '925271095354',
    projectId: 'cause-flutter-mvp',
    databaseURL: 'https://cause-flutter-mvp-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'cause-flutter-mvp.appspot.com',
    iosClientId: '925271095354-0rk0q2ueb9iidtcm2lprmpgctqh2l8c8.apps.googleusercontent.com',
    iosBundleId: 'com.example.causeFlutterMvp',
  );
}
