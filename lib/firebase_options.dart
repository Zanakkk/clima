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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDTuM7J3mAVfZaR54Os7aRqbKQsbrGytgA',
    appId: '1:19027942066:web:b52cf5417f16b82aec07ab',
    messagingSenderId: '19027942066',
    projectId: 'clima-61e37',
    authDomain: 'clima-61e37.firebaseapp.com',
    storageBucket: 'clima-61e37.appspot.com',
    measurementId: 'G-LMY2S3263F',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAchRdKMlje21KODWIhFFowbBaiR9MclTk',
    appId: '1:19027942066:android:5b4ef9e475045f77ec07ab',
    messagingSenderId: '19027942066',
    projectId: 'clima-61e37',
    storageBucket: 'clima-61e37.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCVtaX9w5-wZH9tPSbcD7LNtcq866paCDY',
    appId: '1:19027942066:ios:696531ceb3132461ec07ab',
    messagingSenderId: '19027942066',
    projectId: 'clima-61e37',
    storageBucket: 'clima-61e37.appspot.com',
    iosClientId: '19027942066-enikmmd2b9edpsphpu895doa8iel8q3j.apps.googleusercontent.com',
    iosBundleId: 'com.example.clima',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCVtaX9w5-wZH9tPSbcD7LNtcq866paCDY',
    appId: '1:19027942066:ios:696531ceb3132461ec07ab',
    messagingSenderId: '19027942066',
    projectId: 'clima-61e37',
    storageBucket: 'clima-61e37.appspot.com',
    iosClientId: '19027942066-enikmmd2b9edpsphpu895doa8iel8q3j.apps.googleusercontent.com',
    iosBundleId: 'com.example.clima',
  );
}
