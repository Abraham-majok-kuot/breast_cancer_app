import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_localizations.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get arguments passed from prediction screen
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final double riskScore = args?['riskScore'] ?? 0.35;
    final double age = args?['age'] ?? 35;
    final double bmi = args?['bmi'] ?? 25;
    final bool familyHistory = args?['familyHistory'] ?? false;
    final bool hadBiopsy = args?['hadBiopsy'] ?? false;
    final bool breastfeeding = args?['breastfeeding'] ?? false;
    final bool hormonalContraceptives = args?['hormonalContraceptives'] ?? false;
    final String smoking = args?['smoking'] ?? 'No';
    final String alcohol = args?['alcohol'] ?? 'None';
    final String exercise = args?['exercise'] ?? 'Moderate';
    final String diet = args?['diet'] ?? 'Good';

    // Determine risk level colours / emoji / message
    // riskLevel string is set later after context.l is available
    String riskLevel = '';
    Color riskColor;
    Color riskBg;
    String riskEmoji;
    String riskMessage;

    if (riskScore < 0.25) {
      riskColor = const Color(0xFF4CAF50);
      riskBg = const Color(0xFFE8F5E9);
      riskEmoji = '✅';
      riskMessage = 'Great news! Your current risk factors suggest a low risk. Keep up your healthy habits and continue regular check-ups.';
    } else if (riskScore < 0.55) {
      riskColor = const Color(0xFFFF9800);
      riskBg = const Color(0xFFFFF3E0);
      riskEmoji = '⚠️';
      riskMessage = 'Your results indicate a moderate risk level. Consider discussing your risk factors with a healthcare provider and increasing screening frequency.';
    } else {
      riskColor = const Color(0xFFF44336);
      riskBg = const Color(0xFFFFEBEE);
      riskEmoji = '🔴';
      riskMessage = 'Your results show elevated risk factors. We strongly recommend consulting a healthcare professional soon for a thorough evaluation and screening.';
    }

    // Build risk factors list
    final List<_RiskFactor> riskFactors = [
      _RiskFactor(
        label: 'Age (${age.round()} years)',
        level: age >= 50 ? 'High' : age >= 40 ? 'Moderate' : 'Low',
        icon: Icons.cake_outlined,
      ),
      _RiskFactor(
        label: 'BMI (${bmi.toStringAsFixed(1)})',
        level: bmi >= 30 ? 'High' : bmi >= 25 ? 'Moderate' : 'Low',
        icon: Icons.monitor_weight_outlined,
      ),
      _RiskFactor(
        label: 'Family History',
        level: familyHistory ? 'High' : 'Low',
        icon: Icons.family_restroom,
      ),
      _RiskFactor(
        label: 'Previous Biopsy',
        level: hadBiopsy ? 'Moderate' : 'Low',
        icon: Icons.biotech_outlined,
      ),
      _RiskFactor(
        label: 'Breastfeeding',
        level: breastfeeding ? 'Low' : 'Moderate',
        icon: Icons.child_care_outlined,
      ),
      _RiskFactor(
        label: 'Hormonal Contraceptives',
        level: hormonalContraceptives ? 'Moderate' : 'Low',
        icon: Icons.medication_outlined,
      ),
      _RiskFactor(
        label: 'Smoking: $smoking',
        level: smoking == 'Yes' ? 'High' : smoking == 'Occasionally' ? 'Moderate' : 'Low',
        icon: Icons.smoking_rooms_outlined,
      ),
      _RiskFactor(
        label: 'Alcohol: $alcohol',
        level: alcohol == 'Heavy' ? 'High' : alcohol == 'Moderate' ? 'Moderate' : 'Low',
        icon: Icons.local_bar_outlined,
      ),
      _RiskFactor(
        label: 'Exercise: $exercise',
        level: exercise == 'None' ? 'High' : exercise == 'Light' ? 'Moderate' : 'Low',
        icon: Icons.directions_run_outlined,
      ),
      _RiskFactor(
        label: 'Diet: $diet',
        level: diet == 'Poor' ? 'High' : diet == 'Average' ? 'Moderate' : 'Low',
        icon: Icons.restaurant_outlined,
      ),
    ];

    // Build recommendations
    final List<String> recommendations = _buildRecommendations(
      riskScore: riskScore,
      age: age,
      bmi: bmi,
      familyHistory: familyHistory,
      smoking: smoking,
      alcohol: alcohol,
      exercise: exercise,
      diet: diet,
    );

    final l = context.l;

    // Localise risk level strings (computed before Scaffold)
    if (riskScore < 0.25) {
      riskLevel = l.lowRisk;
    } else if (riskScore < 0.55) {
      riskLevel = l.moderateRisk;
    } else {
      riskLevel = l.highRisk;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: riskColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(l.yourResults,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, '/dashboard', (route) => false),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Share feature coming soon')),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // ── Risk Score Banner ────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              decoration: BoxDecoration(
                color: riskColor,
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Text(riskEmoji, style: const TextStyle(fontSize: 56))
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 12),
                  Text(riskLevel,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold))
                      .animate()
                      .fadeIn(delay: 200.ms),
                  const SizedBox(height: 8),
                  Text(
                    '${(riskScore * 100).toStringAsFixed(1)}% Risk Score',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 16),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 16),
                  // Score bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: riskScore,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 10,
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Risk Message ────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: riskBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: riskColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: riskColor, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(riskMessage,
                              style: TextStyle(
                                  color: riskColor,
                                  fontSize: 13,
                                  height: 1.5)),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 20),

                  // ── Risk Factors Breakdown ──────────────────────
                  Text(l.riskFactorBreakdown,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  ...riskFactors.asMap().entries.map((e) =>
                      _RiskFactorRow(factor: e.value, delay: e.key * 50)),

                  const SizedBox(height: 20),

                  // ── Recommendations ─────────────────────────────
                  Text(l.personalisedRecs,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  ...recommendations.asMap().entries.map((e) =>
                      _RecommendationCard(
                          text: e.value, index: e.key, color: riskColor)),

                  const SizedBox(height: 20),

                  // ── Disclaimer ──────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_outlined,
                            color: Colors.orange, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This assessment is for educational purposes only and does NOT replace professional medical advice. Always consult a qualified healthcare provider for diagnosis and treatment.',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 20),

                  // ── Action Buttons ──────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/input'),
                          icon: const Icon(Icons.refresh),
                          label: Text(l.retake),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: riskColor,
                            side: BorderSide(color: riskColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/dashboard', (r) => false),
                          icon: const Icon(Icons.home_outlined),
                          label: Text(l.home),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: riskColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 12),

                  // ── Education Hub Button ─────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/education'),
                      icon: const Icon(Icons.menu_book_outlined),
                      label: Text(l.visitEducationHub),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00BCD4),
                        side: const BorderSide(color: Color(0xFF00BCD4)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ).animate().fadeIn(delay: 750.ms),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _buildRecommendations({
    required double riskScore,
    required double age,
    required double bmi,
    required bool familyHistory,
    required String smoking,
    required String alcohol,
    required String exercise,
    required String diet,
  }) {
    final recs = <String>[];

    if (familyHistory) {
      recs.add('Due to your family history, consider genetic counselling and discuss BRCA testing with your doctor.');
    }
    if (age >= 40) {
      recs.add('At your age, annual mammograms are recommended. Schedule one if you haven\'t had one recently.');
    }
    if (bmi >= 25) {
      recs.add('Achieving a healthy BMI through balanced diet and regular exercise can significantly reduce your risk.');
    }
    if (smoking == 'Yes' || smoking == 'Occasionally') {
      recs.add('Quitting smoking is one of the best things you can do for your overall health and cancer risk.');
    }
    if (alcohol == 'Heavy' || alcohol == 'Moderate') {
      recs.add('Reducing alcohol consumption to less than 1 drink per day can lower your breast cancer risk by up to 10%.');
    }
    if (exercise == 'None' || exercise == 'Light') {
      recs.add('Aim for at least 150 minutes of moderate exercise per week. Even daily 30-minute walks help.');
    }
    if (diet == 'Poor' || diet == 'Average') {
      recs.add('Improve your diet by adding more fruits, vegetables, and whole grains while reducing processed foods.');
    }

    // Always add these
    recs.add('Perform monthly breast self-exams and report any changes to your doctor immediately.');
    if (riskScore >= 0.4) {
      recs.add('Given your risk level, consider scheduling a clinical breast exam with your doctor within the next 3 months.');
    }

    return recs;
  }
}

class _RiskFactor {
  final String label;
  final String level;
  final IconData icon;
  const _RiskFactor({required this.label, required this.level, required this.icon});
}

class _RiskFactorRow extends StatelessWidget {
  final _RiskFactor factor;
  final int delay;
  const _RiskFactorRow({required this.factor, required this.delay});

  Color get _color {
    switch (factor.level) {
      case 'High': return const Color(0xFFF44336);
      case 'Moderate': return const Color(0xFFFF9800);
      default: return const Color(0xFF4CAF50);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.06), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Icon(factor.icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(factor.label,
                style: const TextStyle(fontSize: 13)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              factor.level,
              style: TextStyle(
                  color: _color, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.1);
  }
}

class _RecommendationCard extends StatelessWidget {
  final String text;
  final int index;
  final Color color;
  const _RecommendationCard(
      {required this.text, required this.index, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.06), blurRadius: 6),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 13, height: 1.5)),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 80 + 500));
  }
}