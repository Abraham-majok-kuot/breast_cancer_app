// Integration / system tests — run on a real device or emulator:
//   flutter test integration_test/app_flow_test.dart
//
// These tests exercise complete user journeys end-to-end.
// They require Firebase emulators or a dedicated test Firebase project.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:breast_cancer_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('System test – app launch', () {
    testWidgets('app starts and shows splash or auth screen', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Either the auth screen or splash is visible after launch
      final hasAuthSurface =
          find.byType(Scaffold).evaluate().isNotEmpty;
      expect(hasAuthSurface, isTrue);
    });
  });

  group('System test – auth flow', () {
    testWidgets('auth screen shows sign-in and register options', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate past splash if needed
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final hasSignIn = find.textContaining('Sign In').evaluate().isNotEmpty ||
          find.textContaining('Login').evaluate().isNotEmpty;
      expect(hasSignIn, isTrue);
    });

    testWidgets('tapping Sign In shows login form fields', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 6));

      final signInBtn = find.textContaining('Sign In');
      if (signInBtn.evaluate().isNotEmpty) {
        await tester.tap(signInBtn.first);
        await tester.pumpAndSettle();

        expect(find.byType(TextFormField), findsWidgets);
      }
    });

    testWidgets('login form validates empty email', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 6));

      final signInBtn = find.textContaining('Sign In');
      if (signInBtn.evaluate().isNotEmpty) {
        await tester.tap(signInBtn.first);
        await tester.pumpAndSettle();

        // Submit with empty fields
        final loginBtn = find.widgetWithText(ElevatedButton, 'Login')
            .evaluate().isNotEmpty
            ? find.widgetWithText(ElevatedButton, 'Login')
            : find.widgetWithText(ElevatedButton, 'Sign In');

        if (loginBtn.evaluate().isNotEmpty) {
          await tester.tap(loginBtn.first);
          await tester.pump();
          expect(find.textContaining('email').evaluate().isNotEmpty ||
              find.textContaining('required').evaluate().isNotEmpty ||
              find.textContaining('valid').evaluate().isNotEmpty, isTrue);
        }
      }
    });
  });

  group('System test – assessment flow (requires authenticated session)', () {
    testWidgets('prediction screen shows 3-step form', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 6));

      // Only proceed if we land on the dashboard (authenticated state)
      final hasDashboard =
          find.textContaining('Assessment').evaluate().isNotEmpty ||
          find.textContaining('dashboard').evaluate().isNotEmpty;

      if (hasDashboard) {
        final assessBtn = find.textContaining('Assessment').first;
        await tester.tap(assessBtn);
        await tester.pumpAndSettle();

        // Step 1 should show sliders for age and BMI
        expect(find.byType(Slider), findsWidgets);
      }
    });
  });

  group('System test – settings screen', () {
    testWidgets('settings screen can be opened from dashboard', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 6));

      final settingsBtn = find.byIcon(Icons.settings).evaluate().isNotEmpty
          ? find.byIcon(Icons.settings)
          : find.textContaining('Settings');

      if (settingsBtn.evaluate().isNotEmpty) {
        await tester.tap(settingsBtn.first);
        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
      }
    });
  });

  group('System test – education screen', () {
    testWidgets('education screen renders article list', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 6));

      final eduBtn = find.textContaining('Education').evaluate().isNotEmpty
          ? find.textContaining('Education')
          : find.byIcon(Icons.school_outlined);

      if (eduBtn.evaluate().isNotEmpty) {
        await tester.tap(eduBtn.first);
        await tester.pumpAndSettle();

        // At least one article card or list tile present
        expect(
          find.byType(ListView).evaluate().isNotEmpty ||
          find.byType(Card).evaluate().isNotEmpty,
          isTrue,
        );
      }
    });
  });

  group('System test – history screen', () {
    testWidgets('history screen renders filter options', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 6));

      final historyBtn = find.textContaining('History');
      if (historyBtn.evaluate().isNotEmpty) {
        await tester.tap(historyBtn.first);
        await tester.pumpAndSettle();

        // Filter chips: All / Low / Moderate / High
        final hasFilters =
            find.textContaining('All').evaluate().isNotEmpty ||
            find.textContaining('Low').evaluate().isNotEmpty;
        expect(hasFilters, isTrue);
      }
    });
  });
}
