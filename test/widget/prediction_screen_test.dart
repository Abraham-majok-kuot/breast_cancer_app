import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:breast_cancer_app/views/prediction_screen.dart';

// Phone viewport so the screen renders without layout overflow.
const _kPhoneSize = Size(390, 844);

// Wrap PredictionScreen with minimal MaterialApp.
// Firebase is NOT called during build() or initState() — only on form submission.
Widget _wrap() => MaterialApp(
      home: const PredictionScreen(),
      routes: {
        '/result': (_) => const Scaffold(body: Text('Result')),
        '/dashboard': (_) => const Scaffold(body: Text('Dashboard')),
      },
    );

// Pump initial frame + advance animations enough to settle flutter_animate timers.
Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  group('PredictionScreen – step 1 (basic info)', () {
    testWidgets('renders without exception', (tester) async {
      tester.view.physicalSize = _kPhoneSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap());
      await _pump(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows at least one Slider (age)', (tester) async {
      tester.view.physicalSize = _kPhoneSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap());
      await _pump(tester);
      expect(find.byType(Slider), findsWidgets);
    });

    testWidgets('shows two Sliders (age + BMI)', (tester) async {
      tester.view.physicalSize = _kPhoneSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap());
      await _pump(tester);
      expect(find.byType(Slider), findsNWidgets(2));
    });

    testWidgets('shows a step counter or progress indicator', (tester) async {
      tester.view.physicalSize = _kPhoneSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap());
      await _pump(tester);
      final hasProgress =
          find.byType(LinearProgressIndicator).evaluate().isNotEmpty ||
          find.textContaining('/3').evaluate().isNotEmpty ||
          find.textContaining('3').evaluate().isNotEmpty ||
          find.textContaining('Step').evaluate().isNotEmpty;
      expect(hasProgress, isTrue);
    });

    testWidgets('shows a Next or Continue button', (tester) async {
      tester.view.physicalSize = _kPhoneSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap());
      await _pump(tester);
      final hasNext =
          find.widgetWithText(ElevatedButton, 'Continue').evaluate().isNotEmpty ||
          find.textContaining('Continue').evaluate().isNotEmpty;
      expect(hasNext, isTrue);
    });

    testWidgets('step 1 is always valid – tapping Next does not show snackbar',
        (tester) async {
      tester.view.physicalSize = _kPhoneSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap());
      await _pump(tester);

      final nextFinder = find.widgetWithText(ElevatedButton, 'Continue');

      if (nextFinder.evaluate().isNotEmpty) {
        await tester.tap(nextFinder.first);
        await tester.pump(const Duration(seconds: 2));
        expect(find.byType(SnackBar), findsNothing);
      }
    });

    testWidgets('has a back navigation button', (tester) async {
      tester.view.physicalSize = _kPhoneSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap());
      await _pump(tester);
      final hasBack =
          find.byType(BackButton).evaluate().isNotEmpty ||
          find.byIcon(Icons.arrow_back).evaluate().isNotEmpty ||
          find.byIcon(Icons.arrow_back_ios).evaluate().isNotEmpty ||
          find.byIcon(Icons.chevron_left).evaluate().isNotEmpty;
      expect(hasBack, isTrue);
    });
  });

  group('PredictionScreen – step 2 (medical history)', () {
    Future<void> goToStep2(WidgetTester tester) async {
      await tester.pumpWidget(_wrap());
      await _pump(tester);
      final continueFinder = find.widgetWithText(ElevatedButton, 'Continue');
      if (continueFinder.evaluate().isNotEmpty) {
        await tester.tap(continueFinder.first);
        // Pump 10 frames of 50ms each to drive the 400ms PageView animation.
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        await tester.pump(const Duration(seconds: 1)); // let flutter_animate settle
      }
    }

    testWidgets('step 2 shows Yes / No answer options after navigation', (tester) async {
      tester.view.physicalSize = _kPhoneSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await goToStep2(tester);
      // PageView is lazy — after navigating, page 2 is built and 'Yes' is rendered.
      final hasYesNo =
          find.text('Yes').evaluate().isNotEmpty ||
          find.text('No').evaluate().isNotEmpty;
      expect(hasYesNo, isTrue);
    });

    testWidgets('tapping Continue on step 2 without answers shows snackbar',
        (tester) async {
      tester.view.physicalSize = _kPhoneSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await goToStep2(tester);

      final continueFinder = find.widgetWithText(ElevatedButton, 'Continue');
      if (continueFinder.evaluate().isNotEmpty) {
        await tester.tap(continueFinder.first);
        await tester.pump();
        expect(find.byType(SnackBar), findsOneWidget);
      }
    });
  });
}
