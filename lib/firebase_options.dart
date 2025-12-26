import 'package:firebase_core/firebase_core.dart';
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
        return windows;
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
    apiKey: 'AIzaSyCtPyX45gkEpxwkC69oY5sRdlLompVV5N0',
    appId: '1:276908933332:android:8db0ba61cb41f211f2bb41',
    messagingSenderId: '276908933332',
    projectId: 'islamic-app-backend',
    storageBucket: 'islamic-app-backend.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBSvISoZQWJuaupiclD0E1QAHr1eFgdQUQ',
    appId: '1:276908933332:ios:f2121a617ad3e493f2bb41',
    messagingSenderId: '276908933332',
    projectId: 'islamic-app-backend',
    storageBucket: 'islamic-app-backend.firebasestorage.app',
    iosClientId: '276908933332-0clsiojjsm4dnccnvk0aave80kqhe7st.apps.googleusercontent.com',
    iosBundleId: 'com.affan.islamicapp',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCt1VzmHVTXwCkIq3B1GnMIC6JKlNbdKXo',
    appId: '1:276908933332:web:f01360a14c8c5eb1f2bb41',
    messagingSenderId: '276908933332',
    projectId: 'islamic-app-backend',
    authDomain: 'islamic-app-backend.firebaseapp.com',
    storageBucket: 'islamic-app-backend.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBSvISoZQWJuaupiclD0E1QAHr1eFgdQUQ',
    appId: '1:276908933332:ios:3fc7b1485d33a57cf2bb41',
    messagingSenderId: '276908933332',
    projectId: 'islamic-app-backend',
    storageBucket: 'islamic-app-backend.firebasestorage.app',
    iosClientId: '276908933332-32guuglfub7p59p8kc5tjhbvfffp0jdc.apps.googleusercontent.com',
    iosBundleId: 'com.islamicapp.islamicApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCt1VzmHVTXwCkIq3B1GnMIC6JKlNbdKXo',
    appId: '1:276908933332:web:f03ed1185aae1cd3f2bb41',
    messagingSenderId: '276908933332',
    projectId: 'islamic-app-backend',
    authDomain: 'islamic-app-backend.firebaseapp.com',
    storageBucket: 'islamic-app-backend.firebasestorage.app',
  );

}