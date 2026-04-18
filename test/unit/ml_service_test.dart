import 'package:flutter_test/flutter_test.dart';
import 'package:breast_cancer_app/views/ml_service.dart';

void main() {
  // TFLite is unavailable in the unit-test environment, so every predict()
  // call falls through to the deterministic rule-based fallback.
  setUp(() => MLService.dispose());

  group('MLService – age brackets', () {
    test('age < 30 contributes 0 to score', () async {
      final score = await MLService.predict(
        age: 25, bmi: 20,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      expect(score, 0.0);
    });

    test('age 30–39 contributes 0.06', () async {
      final score = await MLService.predict(
        age: 35, bmi: 20,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      expect(score, closeTo(0.06, 0.001));
    });

    test('age 40–49 contributes 0.12', () async {
      final score = await MLService.predict(
        age: 45, bmi: 20,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      expect(score, closeTo(0.12, 0.001));
    });

    test('age >= 50 contributes 0.20', () async {
      final score = await MLService.predict(
        age: 60, bmi: 20,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      expect(score, closeTo(0.20, 0.001));
    });
  });

  group('MLService – BMI brackets', () {
    test('BMI < 25 contributes 0', () async {
      final score = await MLService.predict(
        age: 25, bmi: 22,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      expect(score, 0.0);
    });

    test('BMI 25–29 contributes 0.08', () async {
      final score = await MLService.predict(
        age: 25, bmi: 27,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      expect(score, closeTo(0.08, 0.001));
    });

    test('BMI >= 30 contributes 0.15', () async {
      final score = await MLService.predict(
        age: 25, bmi: 32,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      expect(score, closeTo(0.15, 0.001));
    });
  });

  group('MLService – medical history flags', () {
    test('family history adds 0.20', () async {
      final score = await MLService.predict(
        age: 25, bmi: 20,
        familyHistory: true, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      expect(score, closeTo(0.20, 0.001));
    });

    test('had biopsy adds 0.10', () async {
      final score = await MLService.predict(
        age: 25, bmi: 20,
        familyHistory: false, hadBiopsy: true,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      expect(score, closeTo(0.10, 0.001));
    });

    test('no breastfeeding adds 0.05', () async {
      final score = await MLService.predict(
        age: 25, bmi: 20,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: false, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      expect(score, closeTo(0.05, 0.001));
    });

    test('hormonal contraceptives add 0.08', () async {
      final score = await MLService.predict(
        age: 25, bmi: 20,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: true,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      expect(score, closeTo(0.08, 0.001));
    });
  });

  group('MLService – lifestyle factors', () {
    test('smoking No contributes 0', () async {
      final score = await MLService.predict(
        age: 25, bmi: 20,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      expect(score, 0.0);
    });

    test('smoking Occasionally adds 0.05', () async {
      final score = await MLService.predict(
        age: 25, bmi: 20,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'Occasionally', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      expect(score, closeTo(0.05, 0.001));
    });

    test('smoking Yes adds 0.10', () async {
      final score = await MLService.predict(
        age: 25, bmi: 20,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'Yes', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      expect(score, closeTo(0.10, 0.001));
    });

    test('alcohol Light adds 0', () async {
      final none = await MLService.predict(
        age: 25, bmi: 20,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      final light = await MLService.predict(
        age: 25, bmi: 20,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'Light', exercise: 'Active', diet: 'Excellent',
      );
      expect(light, none);
    });

    test('alcohol Moderate adds 0.06', () async {
      final score = await MLService.predict(
        age: 25, bmi: 20,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'Moderate', exercise: 'Active', diet: 'Excellent',
      );
      expect(score, closeTo(0.06, 0.001));
    });

    test('alcohol Heavy adds 0.12', () async {
      final score = await MLService.predict(
        age: 25, bmi: 20,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'Heavy', exercise: 'Active', diet: 'Excellent',
      );
      expect(score, closeTo(0.12, 0.001));
    });

    test('exercise None adds 0.10', () async {
      final score = await MLService.predict(
        age: 25, bmi: 20,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'None', diet: 'Excellent',
      );
      expect(score, closeTo(0.10, 0.001));
    });

    test('exercise Light adds 0.05', () async {
      final score = await MLService.predict(
        age: 25, bmi: 20,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Light', diet: 'Excellent',
      );
      expect(score, closeTo(0.05, 0.001));
    });

    test('exercise Moderate adds 0', () async {
      final score = await MLService.predict(
        age: 25, bmi: 20,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Moderate', diet: 'Excellent',
      );
      expect(score, 0.0);
    });

    test('diet Poor adds 0.08', () async {
      final score = await MLService.predict(
        age: 25, bmi: 20,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Poor',
      );
      expect(score, closeTo(0.08, 0.001));
    });

    test('diet Average adds 0.04', () async {
      final score = await MLService.predict(
        age: 25, bmi: 20,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Average',
      );
      expect(score, closeTo(0.04, 0.001));
    });

    test('diet Good adds 0', () async {
      final score = await MLService.predict(
        age: 25, bmi: 20,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Good',
      );
      expect(score, 0.0);
    });
  });

  group('MLService – score boundaries and combinations', () {
    test('maximum-risk profile clamps to 1.0', () async {
      final score = await MLService.predict(
        age: 60, bmi: 35,
        familyHistory: true, hadBiopsy: true,
        breastfeeding: false, hormonalContraceptives: true,
        smoking: 'Yes', alcohol: 'Heavy', exercise: 'None', diet: 'Poor',
      );
      // Raw sum 1.18 → must clamp to 1.0
      expect(score, 1.0);
    });

    test('score is always in [0.0, 1.0]', () async {
      final score = await MLService.predict(
        age: 18, bmi: 15,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      expect(score, inInclusiveRange(0.0, 1.0));
    });

    test('combined moderate risk (age 45, family history, overweight) ≈ 0.40', () async {
      final score = await MLService.predict(
        age: 45, bmi: 27,
        familyHistory: true, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Moderate', diet: 'Good',
      );
      // 0.12 + 0.08 + 0.20 = 0.40
      expect(score, closeTo(0.40, 0.001));
    });

    test('same inputs return identical scores on repeated calls', () async {
      Future<double> call() => MLService.predict(
        age: 40, bmi: 24,
        familyHistory: true, hadBiopsy: false,
        breastfeeding: false, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Light', diet: 'Average',
      );
      final s1 = await call();
      final s2 = await call();
      expect(s1, s2);
    });

    test('dispose then predict still returns valid score via fallback', () async {
      MLService.dispose();
      final score = await MLService.predict(
        age: 35, bmi: 22,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      expect(score, inInclusiveRange(0.0, 1.0));
    });
  });

  group('MLService – risk level classification thresholds', () {
    test('low risk: score < 0.25', () async {
      final score = await MLService.predict(
        age: 25, bmi: 20,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      expect(score, lessThan(0.25));
    });

    test('moderate risk: score in [0.25, 0.55)', () async {
      // age=40 (+0.12) + BMI=27 (+0.08) + family (+0.20) = 0.40
      final score = await MLService.predict(
        age: 40, bmi: 27,
        familyHistory: true, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Excellent',
      );
      expect(score, inInclusiveRange(0.25, 0.54));
    });

    test('high risk: score >= 0.55', () async {
      final score = await MLService.predict(
        age: 55, bmi: 32,
        familyHistory: true, hadBiopsy: true,
        breastfeeding: false, hormonalContraceptives: true,
        smoking: 'Yes', alcohol: 'Heavy', exercise: 'None', diet: 'Poor',
      );
      expect(score, greaterThanOrEqualTo(0.55));
    });
  });
}
