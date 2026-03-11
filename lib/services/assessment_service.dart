import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssessmentService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // ── Save assessment to Firestore ─────────────────────────────────────────
  static Future<void> saveAssessment(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('assessments')
        .add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'uid': user.uid,
    });
  }

  // ── Get all assessments for current user ─────────────────────────────────
  static Stream<QuerySnapshot> getAssessments() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('assessments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ── Delete a single assessment ────────────────────────────────────────────
  static Future<void> deleteAssessment(String docId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('assessments')
        .doc(docId)
        .delete();
  }

  // ── Delete all assessments ────────────────────────────────────────────────
  static Future<void> deleteAllAssessments() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _db.batch();
    final snapshots = await _db
        .collection('users')
        .doc(user.uid)
        .collection('assessments')
        .get();

    for (final doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}