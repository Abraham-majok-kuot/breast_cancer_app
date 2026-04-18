
import 'package:tflite_flutter/tflite_flutter.dart';

/// ── MLService ────────────────────────────────────────────────────────────────
/// Loads breast_cancer_model.tflite and runs inference using the
/// exact 10 risk factors collected in PredictionScreen.
///
/// Input order (must match train_model.py):
///   0  age                    float  18–80
///   1  bmi                    float  15–45
///   2  familyHistory          float  0.0 or 1.0
///   3  hadBiopsy              float  0.0 or 1.0
///   4  breastfeeding          float  0.0=never, 1.0=yes
///   5  hormonalContraceptives float  0.0 or 1.0
///   6  smoking                float  0.0=No, 0.5=Occasionally, 1.0=Yes
///   7  alcohol                float  0.0=None, 0.33=Light, 0.66=Moderate, 1.0=Heavy
///   8  exercise               float  0.0=None, 0.33=Light, 0.66=Moderate, 1.0=Active
///   9  diet                   float  0.0=Poor, 0.33=Average, 0.66=Good, 1.0=Excellent

class MLService {
  static Interpreter? _interpreter;
  static bool _isInitialised = false;

  // ── Raw min/max for normalisation — matches scaler_params.json ────────────
  static const Map<String, double> _rawMin = {
    'age': 18.0, 'bmi': 15.0,
    'familyHistory': 0.0, 'hadBiopsy': 0.0,
    'breastfeeding': 0.0, 'hormonalContraceptives': 0.0,
    'smoking': 0.0, 'alcohol': 0.0,
    'exercise': 0.0, 'diet': 0.0,
  };

  static const Map<String, double> _rawMax = {
    'age': 80.0, 'bmi': 45.0,
    'familyHistory': 1.0, 'hadBiopsy': 1.0,
    'breastfeeding': 1.0, 'hormonalContraceptives': 1.0,
    'smoking': 1.0, 'alcohol': 1.0,
    'exercise': 1.0, 'diet': 1.0,
  };

  // ── Initialise — call once before first prediction ─────────────────────────
  static Future<void> initialize() async {
    if (_isInitialised) return;
    try {
      _interpreter = await Interpreter.fromAsset(
          'assets/ml/breast_cancer_model.tflite');
      _isInitialised = true;
      print('[MLService] Model loaded successfully');
    } catch (e) {
      print('[MLService] Failed to load model: $e');
      _isInitialised = false;
    }
  }

  // ── Normalise a single value using min-max scaling ─────────────────────────
  static double _normalise(double value, String feature) {
    final min = _rawMin[feature] ?? 0.0;
    final max = _rawMax[feature] ?? 1.0;
    if (max == min) return 0.0;
    return ((value - min) / (max - min)).clamp(0.0, 1.0);
  }

  // ── Convert categorical string answers to float ───────────────────────────
  static double _smokingToFloat(String smoking) {
    switch (smoking) {
      case 'Yes':          return 1.0;
      case 'Occasionally': return 0.5;
      default:             return 0.0; // No
    }
  }

  static double _alcoholToFloat(String alcohol) {
    switch (alcohol) {
      case 'Heavy':    return 1.0;
      case 'Moderate': return 0.66;
      case 'Light':    return 0.33;
      default:         return 0.0; // None
    }
  }

  static double _exerciseToFloat(String exercise) {
    switch (exercise) {
      case 'Active':   return 1.0;
      case 'Moderate': return 0.66;
      case 'Light':    return 0.33;
      default:         return 0.0; // None
    }
  }

  static double _dietToFloat(String diet) {
    switch (diet) {
      case 'Excellent': return 1.0;
      case 'Good':      return 0.66;
      case 'Average':   return 0.33;
      default:          return 0.0; // Poor
    }
  }

  // ── Main prediction method ─────────────────────────────────────────────────
  /// Returns a risk score between 0.0 and 1.0.
  /// Falls back to rule-based scoring if TFLite model is unavailable.
  static Future<double> predict({
    required double age,
    required double bmi,
    required bool familyHistory,
    required bool hadBiopsy,
    required bool breastfeeding,
    required bool hormonalContraceptives,
    required String smoking,
    required String alcohol,
    required String exercise,
    required String diet,
  }) async {
    // Ensure model is loaded
    if (!_isInitialised) {
      await initialize();
    }

    // If model still not available, fall back to rule-based
    if (_interpreter == null) {
      print('[MLService] Model unavailable — using rule-based fallback');
      return _ruleBasedFallback(
        age: age, bmi: bmi,
        familyHistory: familyHistory, hadBiopsy: hadBiopsy,
        breastfeeding: breastfeeding,
        hormonalContraceptives: hormonalContraceptives,
        smoking: smoking, alcohol: alcohol,
        exercise: exercise, diet: diet,
      );
    }

    try {
      // Build raw input vector (10 features in exact order)
      final rawInputs = [
        age,
        bmi,
        familyHistory          ? 1.0 : 0.0,
        hadBiopsy              ? 1.0 : 0.0,
        breastfeeding          ? 1.0 : 0.0,
        hormonalContraceptives ? 1.0 : 0.0,
        _smokingToFloat(smoking),
        _alcoholToFloat(alcohol),
        _exerciseToFloat(exercise),
        _dietToFloat(diet),
      ];

      // Normalise each feature using min-max scaling
      final featureNames = [
        'age', 'bmi', 'familyHistory', 'hadBiopsy',
        'breastfeeding', 'hormonalContraceptives',
        'smoking', 'alcohol', 'exercise', 'diet',
      ];

      final normalised = List<double>.generate(
        rawInputs.length,
        (i) => _normalise(rawInputs[i], featureNames[i]),
      );

      // Prepare input tensor — shape [1, 10]
      final input = [normalised.map((v) => v.toDouble()).toList()];
      final output = List.filled(1, [0.0]);

      // Run inference
      _interpreter!.run(input, output);

   final score = output[0][0].clamp(0.0, 1.0);
      print('[MLService] TFLite prediction: $score');
      return score;
    } catch (e) {
      print('[MLService] Inference error: $e — using fallback');
      return _ruleBasedFallback(
        age: age, bmi: bmi,
        familyHistory: familyHistory, hadBiopsy: hadBiopsy,
        breastfeeding: breastfeeding,
        hormonalContraceptives: hormonalContraceptives,
        smoking: smoking, alcohol: alcohol,
        exercise: exercise, diet: diet,
      );
    }
  }

  // ── Rule-based fallback — identical to your original _calculateRisk() ──────
  static double _ruleBasedFallback({
    required double age,
    required double bmi,
    required bool familyHistory,
    required bool hadBiopsy,
    required bool breastfeeding,
    required bool hormonalContraceptives,
    required String smoking,
    required String alcohol,
    required String exercise,
    required String diet,
  }) {
    double score = 0.0;
    if (age >= 50) {
      score += 0.20;
    } else if (age >= 40)  score += 0.12;
    else if (age >= 30)  score += 0.06;
    if (bmi >= 30) {
      score += 0.15;
    } else if (bmi >= 25)  score += 0.08;
    if (familyHistory)          score += 0.20;
    if (hadBiopsy)              score += 0.10;
    if (!breastfeeding)         score += 0.05;
    if (hormonalContraceptives) score += 0.08;
    if (smoking == 'Yes') {
      score += 0.10;
    } else if (smoking == 'Occasionally') score += 0.05;
    if (alcohol == 'Heavy') {
      score += 0.12;
    } else if (alcohol == 'Moderate') score += 0.06;
    if (exercise == 'None') {
      score += 0.10;
    } else if (exercise == 'Light') score += 0.05;
    if (diet == 'Poor') {
      score += 0.08;
    } else if (diet == 'Average') score += 0.04;
    return score.clamp(0.0, 1.0);
  }

  // ── Dispose ────────────────────────────────────────────────────────────────
  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialised = false;
  }
}