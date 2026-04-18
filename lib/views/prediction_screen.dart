import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ml_service.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;

  double _age = 35;
  double _bmi = 25;

  bool? _familyHistory;
  bool? _hadBiopsy;
  bool? _breastfeeding;
  bool? _hormonalContraceptives;

  String? _smoking;
  String? _alcohol;
  String? _exercise;
  String? _diet;

  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _step1Valid => true;
  bool get _step2Valid =>
      _familyHistory != null &&
      _hadBiopsy != null &&
      _breastfeeding != null &&
      _hormonalContraceptives != null;
  bool get _step3Valid =>
      _smoking != null &&
      _alcohol != null &&
      _exercise != null &&
      _diet != null;

  void _nextStep() {
    if (_currentStep == 0 && !_step1Valid) return;
    if (_currentStep == 1 && !_step2Valid) {
      _showIncompleteSnack();
      return;
    }
    if (_currentStep == 2) {
      if (!_step3Valid) {
        _showIncompleteSnack();
        return;
      }
      _submitPrediction();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep++);
  }

  void _prevStep() {
    if (_currentStep == 0) {
      Navigator.pop(context);
      return;
    }
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep--);
  }

  void _showIncompleteSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please answer all questions before continuing'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // ✅ FIREBASE SAVE + ML PREDICTION ─────────────────────────────────────────
  Future<void> _submitPrediction() async {
    setState(() => _isLoading = true);

    try {
      // ── ML Model prediction — replaces _calculateRisk() ───────────────────
      final double riskScore = await MLService.predict(
        age:                    _age,
        bmi:                    _bmi,
        familyHistory:          _familyHistory  ?? false,
        hadBiopsy:              _hadBiopsy      ?? false,
        breastfeeding:          _breastfeeding  ?? false,
        hormonalContraceptives: _hormonalContraceptives ?? false,
        smoking:                _smoking  ?? 'No',
        alcohol:                _alcohol  ?? 'None',
        exercise:               _exercise ?? 'None',
        diet:                   _diet     ?? 'Average',
      );

      final String riskLevel = riskScore < 0.25
          ? 'Low Risk'
          : riskScore < 0.55
              ? 'Moderate Risk'
              : 'High Risk';

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Save full assessment to users/{uid}/assessments subcollection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('assessments')
            .add({
          'riskScore': riskScore,
          'riskLevel': riskLevel,
          'age': _age,
          'bmi': _bmi,
          'familyHistory': _familyHistory,
          'hadBiopsy': _hadBiopsy,
          'breastfeeding': _breastfeeding,
          'hormonalContraceptives': _hormonalContraceptives,
          'smoking': _smoking,
          'alcohol': _alcohol,
          'exercise': _exercise,
          'diet': _diet,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Update last assessment summary on user document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'lastAssessment': {
            'riskScore': riskScore,
            'riskLevel': riskLevel,
            'date': FieldValue.serverTimestamp(),
          }
        });
      }

      setState(() => _isLoading = false);
      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/result',
        arguments: {
          'riskScore': riskScore,
          'age': _age,
          'bmi': _bmi,
          'familyHistory': _familyHistory,
          'hadBiopsy': _hadBiopsy,
          'breastfeeding': _breastfeeding,
          'hormonalContraceptives': _hormonalContraceptives,
          'smoking': _smoking,
          'alcohol': _alcohol,
          'exercise': _exercise,
          'diet': _diet,
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save assessment: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Risk Assessment',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _prevStep,
        ),
      ),
      body: Column(
        children: [
          // Progress header
          Container(
            color: const Color(0xFFE91E8C),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Step ${_currentStep + 1} of $_totalSteps',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    Text(
                      ['Basic Info', 'Medical History', 'Lifestyle'][_currentStep],
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(_totalSteps, (i) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                            right: i < _totalSteps - 1 ? 6 : 0),
                        height: 6,
                        decoration: BoxDecoration(
                          color: i <= _currentStep
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),

          // Bottom button
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E8C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _currentStep == _totalSteps - 1
                            ? 'Get My Results'
                            : 'Continue',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    String bmiCategory;
    Color bmiColor;
    if (_bmi < 18.5) { bmiCategory = 'Underweight'; bmiColor = Colors.blue; }
    else if (_bmi < 25) { bmiCategory = 'Normal'; bmiColor = Colors.green; }
    else if (_bmi < 30) { bmiCategory = 'Overweight'; bmiColor = Colors.orange; }
    else { bmiCategory = 'Obese'; bmiColor = Colors.red; }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.person_outline,
            title: 'Basic Information',
            subtitle: 'Tell us about yourself to personalise your assessment',
          ).animate().fadeIn(),
          const SizedBox(height: 24),
          _SliderCard(
            label: 'Age',
            value: _age.round().toString(),
            unit: 'years',
            icon: Icons.cake_outlined,
            color: const Color(0xFFE91E8C),
            child: Column(
              children: [
                Slider(
                  value: _age,
                  min: 18,
                  max: 80,
                  divisions: 62,
                  activeColor: const Color(0xFFE91E8C),
                  onChanged: (v) => setState(() => _age = v),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('18', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text('80', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 16),
          _SliderCard(
            label: 'BMI (Body Mass Index)',
            value: _bmi.toStringAsFixed(1),
            unit: bmiCategory,
            unitColor: bmiColor,
            icon: Icons.monitor_weight_outlined,
            color: bmiColor,
            child: Column(
              children: [
                Slider(
                  value: _bmi,
                  min: 15,
                  max: 45,
                  divisions: 60,
                  activeColor: bmiColor,
                  onChanged: (v) => setState(() => _bmi = v),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('15', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text('45', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE91E8C).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE91E8C).withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFFE91E8C), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'BMI = weight(kg) / height(m)². Use a BMI calculator if needed.',
                    style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.medical_information_outlined,
            title: 'Medical History',
            subtitle: 'Answer honestly — this information is private and secure',
          ).animate().fadeIn(),
          const SizedBox(height: 24),
          _YesNoCard(
            question: 'Does anyone in your immediate family (mother, sister, daughter) have or had breast cancer?',
            icon: Icons.family_restroom,
            color: const Color(0xFFE91E8C),
            value: _familyHistory,
            onChanged: (v) => setState(() => _familyHistory = v),
            delay: 100,
          ),
          _YesNoCard(
            question: 'Have you ever had a breast biopsy or been diagnosed with a benign breast condition?',
            icon: Icons.biotech_outlined,
            color: const Color(0xFF7C4DFF),
            value: _hadBiopsy,
            onChanged: (v) => setState(() => _hadBiopsy = v),
            delay: 200,
          ),
          _YesNoCard(
            question: 'Have you ever breastfed a child?',
            icon: Icons.child_care_outlined,
            color: const Color(0xFF4CAF50),
            value: _breastfeeding,
            onChanged: (v) => setState(() => _breastfeeding = v),
            delay: 300,
          ),
          _YesNoCard(
            question: 'Are you currently using or have you used hormonal contraceptives (pills, injections, implants) for more than 5 years?',
            icon: Icons.medication_outlined,
            color: const Color(0xFFFF9800),
            value: _hormonalContraceptives,
            onChanged: (v) => setState(() => _hormonalContraceptives = v),
            delay: 400,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.self_improvement_outlined,
            title: 'Lifestyle Factors',
            subtitle: 'Your daily habits affect your long-term health risk',
          ).animate().fadeIn(),
          const SizedBox(height: 24),
          _ChoiceCard(
            question: 'Do you smoke or use tobacco?',
            icon: Icons.smoking_rooms_outlined,
            color: const Color(0xFFE91E8C),
            options: const ['No', 'Occasionally', 'Yes'],
            selected: _smoking,
            onChanged: (v) => setState(() => _smoking = v),
            delay: 100,
          ),
          _ChoiceCard(
            question: 'How much alcohol do you consume?',
            icon: Icons.local_bar_outlined,
            color: const Color(0xFF7C4DFF),
            options: const ['None', 'Light', 'Moderate', 'Heavy'],
            selected: _alcohol,
            onChanged: (v) => setState(() => _alcohol = v),
            delay: 200,
          ),
          _ChoiceCard(
            question: 'How often do you exercise per week?',
            icon: Icons.directions_run_outlined,
            color: const Color(0xFF4CAF50),
            options: const ['None', 'Light', 'Moderate', 'Active'],
            selected: _exercise,
            onChanged: (v) => setState(() => _exercise = v),
            delay: 300,
          ),
          _ChoiceCard(
            question: 'How would you describe your diet?',
            icon: Icons.restaurant_outlined,
            color: const Color(0xFFFF9800),
            options: const ['Poor', 'Average', 'Good', 'Excellent'],
            selected: _diet,
            onChanged: (v) => setState(() => _diet = v),
            delay: 400,
          ),
        ],
      ),
    );
  }
}

// ── Reusable Widgets ──────────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _StepHeader({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE91E8C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFFE91E8C), size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SliderCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;
  final Widget child;
  final Color? unitColor;

  const _SliderCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
    required this.child,
    this.unitColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
                Text(value,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(width: 6),
                Text(unit,
                    style: TextStyle(
                        fontSize: 12,
                        color: unitColor ?? Colors.grey,
                        fontWeight: unitColor != null ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          ),
          child,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _YesNoCard extends StatelessWidget {
  final String question;
  final IconData icon;
  final Color color;
  final bool? value;
  final ValueChanged<bool> onChanged;
  final int delay;

  const _YesNoCard({
    required this.question,
    required this.icon,
    required this.color,
    required this.value,
    required this.onChanged,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: value != null ? Border.all(color: color.withOpacity(0.4), width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.07), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(question,
                    style: const TextStyle(fontSize: 13, height: 1.5)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _OptionButton(
                  label: 'Yes',
                  selected: value == true,
                  color: color,
                  onTap: () => onChanged(true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OptionButton(
                  label: 'No',
                  selected: value == false,
                  color: color,
                  onTap: () => onChanged(false),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.1);
  }
}

class _ChoiceCard extends StatelessWidget {
  final String question;
  final IconData icon;
  final Color color;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onChanged;
  final int delay;

  const _ChoiceCard({
    required this.question,
    required this.icon,
    required this.color,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: selected != null ? Border.all(color: color.withOpacity(0.4), width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.07), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(question,
                    style: const TextStyle(fontSize: 13, height: 1.5)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((opt) => _OptionButton(
              label: opt,
              selected: selected == opt,
              color: color,
              onTap: () => onChanged(opt),
            )).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.1);
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color : Colors.grey.shade300),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}