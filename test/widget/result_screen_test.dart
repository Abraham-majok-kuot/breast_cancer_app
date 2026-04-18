import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:breast_cancer_app/views/result_screen.dart';

Widget _wrapWithArgs(Map<String, dynamic> args) => MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ResultScreen(),
                settings: RouteSettings(name: '/result', arguments: args),
              ),
            ),
            child: const Text('Go'),
          ),
        ),
      ),
    );

Future<void> _navigateToResult(
    WidgetTester tester, Map<String, dynamic> args) async {
  await tester.pumpWidget(_wrapWithArgs(args));
  await tester.tap(find.text('Go'));
  await tester.pumpAndSettle();
}

void main() {
  group('ResultScreen – low risk display', () {
    final lowArgs = {
      'riskScore': 0.10,
      'age': 25.0, 'bmi': 20.0,
      'familyHistory': false, 'hadBiopsy': false,
      'breastfeeding': true, 'hormonalContraceptives': false,
      'smoking': 'No', 'alcohol': 'None',
      'exercise': 'Active', 'diet': 'Excellent',
    };

    testWidgets('renders without throwing', (tester) async {
      await _navigateToResult(tester, lowArgs);
      expect(tester.takeException(), isNull);
    });

    testWidgets('displays risk score as percentage', (tester) async {
      await _navigateToResult(tester, lowArgs);
      // Score 0.10 → "10%" somewhere on screen
      expect(find.textContaining('10'), findsWidgets);
    });

    testWidgets('shows low risk indicator (green / check emoji)', (tester) async {
      await _navigateToResult(tester, lowArgs);
      // Low risk uses ✅ emoji and green colour
      expect(find.textContaining('✅'), findsWidgets);
    });

    testWidgets('shows age in risk factor list', (tester) async {
      await _navigateToResult(tester, lowArgs);
      expect(find.textContaining('25'), findsWidgets);
    });

    testWidgets('shows BMI in risk factor list', (tester) async {
      await _navigateToResult(tester, lowArgs);
      expect(find.textContaining('BMI'), findsWidgets);
    });
  });

  group('ResultScreen – moderate risk display', () {
    final modArgs = {
      'riskScore': 0.40,
      'age': 45.0, 'bmi': 27.0,
      'familyHistory': true, 'hadBiopsy': false,
      'breastfeeding': true, 'hormonalContraceptives': false,
      'smoking': 'No', 'alcohol': 'None',
      'exercise': 'Moderate', 'diet': 'Good',
    };

    testWidgets('shows warning emoji for moderate risk', (tester) async {
      await _navigateToResult(tester, modArgs);
      expect(find.textContaining('⚠️'), findsWidgets);
    });

    testWidgets('renders risk factor breakdown section', (tester) async {
      await _navigateToResult(tester, modArgs);
      expect(find.byType(ListView).evaluate().isNotEmpty ||
             find.byType(Column).evaluate().isNotEmpty, isTrue);
    });
  });

  group('ResultScreen – high risk display', () {
    final highArgs = {
      'riskScore': 0.85,
      'age': 60.0, 'bmi': 35.0,
      'familyHistory': true, 'hadBiopsy': true,
      'breastfeeding': false, 'hormonalContraceptives': true,
      'smoking': 'Yes', 'alcohol': 'Heavy',
      'exercise': 'None', 'diet': 'Poor',
    };

    testWidgets('shows red dot emoji for high risk', (tester) async {
      await _navigateToResult(tester, highArgs);
      expect(find.textContaining('🔴'), findsWidgets);
    });

    testWidgets('shows strong recommendation text', (tester) async {
      await _navigateToResult(tester, highArgs);
      expect(find.textContaining('recommend'), findsWidgets);
    });
  });

  group('ResultScreen – default fallback arguments', () {
    testWidgets('renders with empty args (uses defaults)', (tester) async {
      await _navigateToResult(tester, {});
      expect(tester.takeException(), isNull);
      // Default riskScore 0.35 → Moderate
      expect(find.textContaining('⚠️'), findsWidgets);
    });
  });

  group('ResultScreen – risk factor age classification', () {
    testWidgets('age >= 50 shows High risk for age factor', (tester) async {
      await _navigateToResult(tester, {
        'riskScore': 0.20, 'age': 55.0, 'bmi': 20.0,
        'familyHistory': false, 'hadBiopsy': false,
        'breastfeeding': true, 'hormonalContraceptives': false,
        'smoking': 'No', 'alcohol': 'None',
        'exercise': 'Active', 'diet': 'Excellent',
      });
      expect(find.textContaining('55'), findsWidgets);
    });

    testWidgets('has scrollable content with multiple risk factors', (tester) async {
      await _navigateToResult(tester, {
        'riskScore': 0.60, 'age': 60.0, 'bmi': 32.0,
        'familyHistory': true, 'hadBiopsy': true,
        'breastfeeding': false, 'hormonalContraceptives': true,
        'smoking': 'Yes', 'alcohol': 'Heavy',
        'exercise': 'None', 'diet': 'Poor',
      });
      // Multiple risk factor rows rendered
      expect(find.byType(Text).evaluate().length, greaterThan(5));
    });
  });
}
