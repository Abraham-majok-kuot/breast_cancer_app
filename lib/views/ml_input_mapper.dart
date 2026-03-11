/* ── MLInputMapper ────────────────────────────────────────────────────────────
/// Converts raw user form inputs into a normalized float32 tensor
/// that the TFLite model expects as input.
///
/// Input tensor shape: [1, 10] — 1 sample, 10 features
///
/// Feature order (must match training order exactly):
///   0. age                      normalized: value / 80.0
///   1. bmi                      normalized: value / 45.0
///   2. familyHistory            binary: 1.0 = yes, 0.0 = no
///   3. hadBiopsy                binary: 1.0 = yes, 0.0 = no
///   4. breastfeeding            binary: 1.0 = yes, 0.0 = no
///   5. hormonalContraceptives   binary: 1.0 = yes, 0.0 = no
///   6. smoking                  No=0.0, Occasionally=0.5, Yes=1.0
///   7. alcohol                  None=0.0, Light=0.33, Moderate=0.67, Heavy=1.0
///   8. exercise                 None=0.0, Light=0.33, Moderate=0.67, Active=1.0
///   9. diet                     Poor=0.0, Average=0.33, Good=0.67, Excellent=1.0

class MLInputMapper {
  /// Convert the raw form data map into a normalized [1, 10] input tensor.
  static List<List<double>> toInputTensor(Map<String, dynamic> data) {
    final double age = (data['age'] as double? ?? 35.0);
    final double bmi = (data['bmi'] as double? ?? 25.0);
    final bool familyHistory = data['familyHistory'] as bool? ?? false;
    final bool hadBiopsy = data['hadBiopsy'] as bool? ?? false;
    final bool breastfeeding = data['breastfeeding'] as bool? ?? false;
    final bool hormonalContraceptives = data['hormonalContraceptives'] as bool? ?? false;
    final String smoking = data['smoking'] as String? ?? 'No';
    final String alcohol = data['alcohol'] as String? ?? 'None';
    final String exercise = data['exercise'] as String? ?? 'None';
    final String diet = data['diet'] as String? ?? 'Poor';

    final List<double> features = [
      _normalize(age, 18.0, 80.0),
      _normalize(bmi, 15.0, 45.0),
      familyHistory ? 1.0 : 0.0,
      hadBiopsy ? 1.0 : 0.0,
      breastfeeding ? 1.0 : 0.0,
      hormonalContraceptives ? 1.0 : 0.0,
      _encodeSmoking(smoking),
      _encodeAlcohol(alcohol),
      _encodeExercise(exercise),
      _encodeDiet(diet),
    ];

    return [features]; // shape [1, 10]
  }

  static double _normalize(double value, double min, double max) =>
      ((value - min) / (max - min)).clamp(0.0, 1.0);

  static double _encodeSmoking(String v) {
    switch (v) {
      case 'Yes': return 1.0;
      case 'Occasionally': return 0.5;
      default: return 0.0;
    }
  }

  static double _encodeAlcohol(String v) {
    switch (v) {
      case 'Heavy': return 1.0;
      case 'Moderate': return 0.67;
      case 'Light': return 0.33;
      default: return 0.0;
    }
  }

  static double _encodeExercise(String v) {
    switch (v) {
      case 'Active': return 1.0;
      case 'Moderate': return 0.67;
      case 'Light': return 0.33;
      default: return 0.0;
    }
  }

  static double _encodeDiet(String v) {
    switch (v) {
      case 'Excellent': return 1.0;
      case 'Good': return 0.67;
      case 'Average': return 0.33;
      default: return 0.0;
    }
  }
}
*/