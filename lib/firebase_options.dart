import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDiPwHgR6RQXDO-encdCD2wFiU2wWQKEKM',
    appId: '1:389878110289:android:f959c927aabdd60c1c0070',
    messagingSenderId: '389878110289',
    projectId: 'final-year-project-app-7cc02',
    storageBucket: 'final-year-project-app-7cc02.firebasestorage.app',
  );
}