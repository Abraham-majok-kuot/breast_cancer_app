import 'package:flutter_test/flutter_test.dart';
import 'package:breast_cancer_app/views/ml_service.dart';

// Tests that verify the business-level risk classification logic used throughout
// the app (result_screen.dart, history_screen.dart, analytics_screen.dart).
// Risk thresholds: Low < 0.25, Moderate [0.25, 0.55), High >= 0.55

String _classify(double score) {
  if (score < 0.25) return 'Low';
  if (score < 0.55) return 'Moderate';
  return 'High';
}

void main() {
  setUp(() => MLService.dispose());

  group('Risk classification – boundary values', () {
    test('score 0.00 → Low', () => expect(_classify(0.00), 'Low'));
    test('score 0.10 → Low', () => expect(_classify(0.10), 'Low'));
    test('score 0.24 → Low', () => expect(_classify(0.24), 'Low'));
    test('score 0.25 → Moderate', () => expect(_classify(0.25), 'Moderate'));
    test('score 0.40 → Moderate', () => expect(_classify(0.40), 'Moderate'));
    test('score 0.54 → Moderate', () => expect(_classify(0.54), 'Moderate'));
    test('score 0.55 → High', () => expect(_classify(0.55), 'High'));
    test('score 0.80 → High', () => expect(_classify(0.80), 'High'));
    test('score 1.00 → High', () => expect(_classify(1.00), 'High'));
  });

  group('Risk classification – integration with MLService', () {
    test('minimum-risk profile is classified Low', () async {
      final score = await MLService.predict(
        age: 25, bmi: 20,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      expect(_classify(score), 'Low');
    });

    test('middle-risk profile is classified Moderate', () async {
      // age=45(+0.12) + bmi=27(+0.08) + familyHistory(+0.20) = 0.40
      final score = await MLService.predict(
        age: 45, bmi: 27,
        familyHistory: true, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Moderate', diet: 'Good',
      );
      expect(_classify(score), 'Moderate');
    });

    test('high-risk profile is classified High', () async {
      final score = await MLService.predict(
        age: 55, bmi: 32,
        familyHistory: true, hadBiopsy: true,
        breastfeeding: false, hormonalContraceptives: true,
        smoking: 'Yes', alcohol: 'Heavy', exercise: 'None', diet: 'Poor',
      );
      expect(_classify(score), 'High');
    });
  });

  group('Risk score – factor contribution ordering', () {
    test('family history has more impact than single lifestyle factor', () async {
      final withFamilyHistory = await MLService.predict(
        age: 25, bmi: 20,
        familyHistory: true, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      final withSmokingOnly = await MLService.predict(
        age: 25, bmi: 20,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'Yes', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      expect(withFamilyHistory, greaterThan(withSmokingOnly));
    });

    test('more risk factors produce higher score than fewer', () async {
      final lowRisk = await MLService.predict(
        age: 25, bmi: 20,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      final highRisk = await MLService.predict(
        age: 55, bmi: 32,
        familyHistory: true, hadBiopsy: true,
        breastfeeding: false, hormonalContraceptives: true,
        smoking: 'Yes', alcohol: 'Heavy', exercise: 'None', diet: 'Poor',
      );
      expect(highRisk, greaterThan(lowRisk));
    });

    test('older age consistently increases score vs younger age (same profile)', () async {
      final young = await MLService.predict(
        age: 25, bmi: 22,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      final old = await MLService.predict(
        age: 60, bmi: 22,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      expect(old, greaterThan(young));
    });
  });
}
