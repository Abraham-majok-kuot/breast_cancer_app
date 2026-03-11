//import 'package:tflite_flutter/tflite_flutter.dart';
//import 'ml_model_loader.dart';
//import 'ml_input_mapper.dart';

/// ── MLInferenceService ───────────────────────────────────────────────────────
/// Orchestrates the full ML prediction pipeline:
///   1. Loads the TFLite model via MLModelLoader
///   2. Converts user inputs to tensor via MLInputMapper
///   3. Runs inference on the interpreter
///   4. Interprets the output probabilities into a risk result
///
/// Output tensor shape: [1, 3]
///   Index 0 → Low Risk probability
///   Index 1 → Moderate Risk probability
///   Index 2 → High Risk probability
///
/// Automatically falls back to deterministic scoring if model fails.

/*class MLInferenceService {
  /// Run prediction on [data]. Returns MLResult with risk level + probabilities.
  static Future<MLResult> predict(Map<String, dynamic> data) async {
    try {
      // Step 1: Load model
      final Interpreter interpreter = await MLModelLoader.load();

      // Step 2: Prepare input [1, 10]
      final List<List<double>> input = MLInputMapper.toInputTensor(data);

      // Step 3: Prepare output buffer [1, 3]
      final List<List<double>> output = List.generate(1, (_) => List.filled(3, 0.0));

      // Step 4: Run inference
      interpreter.run(input, output);

      // Step 5: Read probabilities
      final double lowProb      = output[0][0];
      final double moderateProb = output[0][1];
      final double highProb     = output[0][2];

       print('[MLInferenceService] Low: $lowProb  Moderate: $moderateProb  High: $highProb');

      // Step 6: Pick highest probability as predicted class
      String riskLevel;
      double riskScore;

      if (highProb >= moderateProb && highProb >= lowProb) {
        riskLevel = 'High Risk';
        riskScore = highProb;
      } else if (moderateProb >= lowProb) {
        riskLevel = 'Moderate Risk';
        riskScore = moderateProb;
      } else {
        riskLevel = 'Low Risk';
        riskScore = lowProb;
      }

      return MLResult(
        riskLevel: riskLevel,
        riskScore: riskScore,
        lowProbability: lowProb,
        moderateProbability: moderateProb,
        highProbability: highProb,
        usedMLModel: true,
      );
    } catch (e) {
      // ✅ Model not ready yet — fall back to deterministic scoring
       print('[MLInferenceService] Fallback scoring used — $e');
      return _fallbackScoring(data);
    }
  }

  /// Deterministic weighted scoring — used when TFLite model is unavailable.
  static MLResult _fallbackScoring(Map<String, dynamic> data) {
    double score = 0.0;

    final double age  = (data['age'] as double? ?? 35.0);
    final double bmi  = (data['bmi'] as double? ?? 25.0);
    final bool fh     = data['familyHistory'] as bool? ?? false;
    final bool biopsy = data['hadBiopsy'] as bool? ?? false;
    final bool bf     = data['breastfeeding'] as bool? ?? false;
    final bool hc     = data['hormonalContraceptives'] as bool? ?? false;
    final String sm   = data['smoking'] as String? ?? 'No';
    final String al   = data['alcohol'] as String? ?? 'None';
    final String ex   = data['exercise'] as String? ?? 'None';
    final String di   = data['diet'] as String? ?? 'Poor';

    if (age >= 50)      score += 0.20;
    else if (age >= 40) score += 0.12;
    else if (age >= 30) score += 0.06;

    if (bmi >= 30)      score += 0.15;
    else if (bmi >= 25) score += 0.08;

    if (fh)     score += 0.20;
    if (biopsy) score += 0.10;
    if (!bf)    score += 0.05;
    if (hc)     score += 0.08;

    if (sm == 'Yes')          score += 0.10;
    else if (sm == 'Occasionally') score += 0.05;

    if (al == 'Heavy')        score += 0.12;
    else if (al == 'Moderate') score += 0.06;

    if (ex == 'None')         score += 0.10;
    else if (ex == 'Light')   score += 0.05;

    if (di == 'Poor')         score += 0.08;
    else if (di == 'Average') score += 0.04;

    score = score.clamp(0.0, 1.0);

    final String riskLevel = score < 0.25
        ? 'Low Risk'
        : score < 0.55
            ? 'Moderate Risk'
            : 'High Risk';

    return MLResult(
      riskLevel: riskLevel,
      riskScore: score,
      lowProbability:      riskLevel == 'Low Risk'      ? score : 0.0,
      moderateProbability: riskLevel == 'Moderate Risk' ? score : 0.0,
      highProbability:     riskLevel == 'High Risk'     ? score : 0.0,
      usedMLModel: false,
    );
  }
}

// ── MLResult data class ───────────────────────────────────────────────────────

class MLResult {
  final String riskLevel;           // 'Low Risk' / 'Moderate Risk' / 'High Risk'
  final double riskScore;           // 0.0 – 1.0
  final double lowProbability;
  final double moderateProbability;
  final double highProbability;
  final bool usedMLModel;           // true = TFLite, false = fallback

  const MLResult({
    required this.riskLevel,
    required this.riskScore,
    required this.lowProbability,
    required this.moderateProbability,
    required this.highProbability,
    required this.usedMLModel,
  });

  /// Convert to Map for passing as Navigator arguments to /result screen
  Map<String, dynamic> toMap() => {
    'riskLevel': riskLevel,
    'riskScore': riskScore,
    'lowProbability': lowProbability,
    'moderateProbability': moderateProbability,
    'highProbability': highProbability,
    'usedMLModel': usedMLModel,
  };
}*/