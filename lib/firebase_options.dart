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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyALJLhQvGmirjrmw11Iou454k5-giFvcUU',
    appId: '1:261849237371:web:9d835b4eaeb2afcb1a1fde',
    messagingSenderId: '261849237371',
    projectId: 'fpl-wordle',
    authDomain: 'fpl-wordle.firebaseapp.com',
    storageBucket: 'fpl-wordle.appspot.com',
    measurementId: 'G-W6KCBY9MQZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBBcZtQScryIqNofRPQQkR1Nf3vYlBzL_8',
    appId: '1:261849237371:android:f6f3dee2726b4ee21a1fde',
    messagingSenderId: '261849237371',
    projectId: 'fpl-wordle',
    storageBucket: 'fpl-wordle.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD7k6YDhEshqCbyPlirDB3ATza4CJBVwxE',
    appId: '1:261849237371:ios:7a6d46cf012a15f11a1fde',
    messagingSenderId: '261849237371',
    projectId: 'fpl-wordle',
    storageBucket: 'fpl-wordle.appspot.com',
    iosClientId: '261849237371-ig1vv7m4hi739jlhbt0f5c91k7vbprf6.apps.googleusercontent.com',
    iosBundleId: 'com.fantasyfootballguesser.ffg',
  );
}
