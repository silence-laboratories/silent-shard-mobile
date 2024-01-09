// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyD3ykrpx5yIP3xBTz0YT9qt8mClooXHvMo',
    appId: '1:738210301394:android:75d9ab9de2436404bfb40b',
    messagingSenderId: '738210301394',
    projectId: 'mobile-wallet-mm-snap',
    storageBucket: 'mobile-wallet-mm-snap.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCAuyrRmA1Pp-nwrqMrE6EgbAtkvyzPXMY',
    appId: '1:738210301394:ios:96007c4239de343ebfb40b',
    messagingSenderId: '738210301394',
    projectId: 'mobile-wallet-mm-snap',
    storageBucket: 'mobile-wallet-mm-snap.appspot.com',
    androidClientId: '738210301394-8839mh1n0bcmucgbfpmr736sgrijqg5l.apps.googleusercontent.com',
    iosClientId: '738210301394-ddj5ls2bsvledntj9o9u3sd005rgdht1.apps.googleusercontent.com',
    iosBundleId: 'com.silencelaboratories.silentshard',
  );
}
