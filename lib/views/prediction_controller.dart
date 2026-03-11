/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ml_inference_service.dart';

/// ── PredictionController ─────────────────────────────────────────────────────
/// Top-level controller called by PredictionScreen.
///
/// Ties together:
///   1. MLInferenceService  — runs the ML prediction
///   2. Firebase Firestore  — saves result to user's assessment history
///
/// Keeps PredictionScreen clean — screen only handles UI/navigation,
/// this file handles all business logic.
///
/// Usage in PredictionScreen:
///   final result = await PredictionController.runAndSave(data);
///   Navigator.pushReplacementNamed(context, '/result', arguments: result.toMap());

class PredictionController {
  /// Run ML prediction and save to Firestore in one call.
  static Future<MLResult> runAndSave(Map<String, dynamic> data) async {
    // Step 1: Run ML model (or fallback)
    final MLResult result = await MLInferenceService.predict(data);

    // Step 2: Persist to Firestore
    await _saveToFirestore(data, result);

    return result;
  }

  static Future<void> _saveToFirestore(
    Map<String, dynamic> inputData,
    MLResult result,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = {
      // User inputs
      'age':                    inputData['age'],
      'bmi':                    inputData['bmi'],
      'familyHistory':          inputData['familyHistory'],
      'hadBiopsy':              inputData['hadBiopsy'],
      'breastfeeding':          inputData['breastfeeding'],
      'hormonalContraceptives': inputData['hormonalContraceptives'],
      'smoking':                inputData['smoking'],
      'alcohol':                inputData['alcohol'],
      'exercise':               inputData['exercise'],
      'diet':                   inputData['diet'],

      // ML outputs
      'riskLevel':              result.riskLevel,
      'riskScore':              result.riskScore,
      'lowProbability':         result.lowProbability,
      'moderateProbability':    result.moderateProbability,
      'highProbability':        result.highProbability,
      'usedMLModel':            result.usedMLModel,

      // Metadata
      'createdAt':              FieldValue.serverTimestamp(),
      'uid':                    user.uid,
    };

    // Save full record to subcollection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('assessments')
        .add(doc);

    // Update quick-access summary on user document
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'lastAssessment': {
        'riskLevel':   result.riskLevel,
        'riskScore':   result.riskScore,
        'date':        FieldValue.serverTimestamp(),
        'usedMLModel': result.usedMLModel,
      }
    });

     print('[PredictionController] Saved to Firestore ✅');
  }
}*/