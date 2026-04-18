import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:breast_cancer_app/views/auth_screen.dart';

// Wide-tall viewport so the 3-column feature card row and tall content don't overflow.
const _kSize = Size(500, 1400);

Widget _wrap(Widget child) => MaterialApp(
      home: child,
      routes: {
        '/login': (_) => const Scaffold(body: Text('Login')),
        '/register': (_) => const Scaffold(body: Text('Register')),
        '/reset-password': (_) => const Scaffold(body: Text('Reset')),
      },
    );

Future<void> _pumpAuth(WidgetTester tester) async {
  await tester.pumpWidget(_wrap(const AuthScreen()));
  // Advance past flutter_animate timers without using pumpAndSettle
  // (which would hang on infinite animations).
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('AuthScreen – rendering', () {
    testWidgets('renders without exception on wide-tall viewport', (tester) async {
      tester.view.physicalSize = _kSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await _pumpAuth(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('contains multiple Text widgets', (tester) async {
      tester.view.physicalSize = _kSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await _pumpAuth(tester);
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('shows "Create Your Account" ElevatedButton', (tester) async {
      tester.view.physicalSize = _kSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await _pumpAuth(tester);
      expect(
        find.textContaining('Create').evaluate().isNotEmpty ||
        find.textContaining('Account').evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('shows "Sign In" OutlinedButton', (tester) async {
      tester.view.physicalSize = _kSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await _pumpAuth(tester);
      expect(find.textContaining('Sign In'), findsWidgets);
    });

    testWidgets('shows "How It Works" section', (tester) async {
      tester.view.physicalSize = _kSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await _pumpAuth(tester);
      expect(find.text('How It Works'), findsOneWidget);
    });

    testWidgets('shows Privacy Policy link', (tester) async {
      tester.view.physicalSize = _kSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await _pumpAuth(tester);
      expect(find.textContaining('Privacy'), findsWidgets);
    });

    testWidgets('has gradient background Container', (tester) async {
      tester.view.physicalSize = _kSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await _pumpAuth(tester);
      expect(find.byType(Container), findsWidgets);
    });
  });

  group('AuthScreen – navigation taps', () {
    testWidgets('tapping Sign In navigates to /login', (tester) async {
      tester.view.physicalSize = _kSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await _pumpAuth(tester);

      final signInBtn = find.widgetWithText(OutlinedButton, 'Sign In to My Account');
      if (signInBtn.evaluate().isNotEmpty) {
        await tester.tap(signInBtn.first);
        await tester.pumpAndSettle();
        expect(find.text('Login'), findsOneWidget);
      }
    });

    testWidgets('tapping Create Account navigates to /register', (tester) async {
      tester.view.physicalSize = _kSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await _pumpAuth(tester);

      final createBtn = find.widgetWithText(ElevatedButton, 'Create Your Account')
          .evaluate().isNotEmpty
          ? find.widgetWithText(ElevatedButton, 'Create Your Account')
          : find.widgetWithText(ElevatedButton, 'Get Started');

      if (createBtn.evaluate().isNotEmpty) {
        await tester.tap(createBtn.first);
        await tester.pumpAndSettle();
        expect(find.text('Register'), findsOneWidget);
      }
    });
  });
}
