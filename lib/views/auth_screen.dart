import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE91E8C), Color(0xFF9C27B0), Color(0xFF7C4DFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [

                // ── Floating decorative circles ──────────────────
                SizedBox(
                  height: screenHeight * 0.42,
                  child: Stack(
                    children: [
                      // Big blurred circle top right
                      Positioned(
                        top: -40,
                        right: -40,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: .07),
                          ),
                        ),
                      ),
                      // Small circle bottom left
                      Positioned(
                        bottom: 20,
                        left: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: .06),
                          ),
                        ),
                      ),

                      // Main content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // App badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.local_hospital,
                                      color: Colors.white, size: 14),
                                  SizedBox(width: 6),
                                  Text(
                                    'Early Detection Saves Lives',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),

                            const SizedBox(height: 28),

                            // Main headline
                            const Text(
                              'Breast Cancer\nRisk Assessment',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                            const SizedBox(height: 14),

                            const Text(
                              'Take a quick assessment to understand\nyour risk and get personalised care.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                height: 1.6,
                              ),
                            ).animate().fadeIn(delay: 300.ms),

                            const SizedBox(height: 28),

                            // Stats row
                            Row(
                              children: [
                                _StatPill(value: '95%', label: 'Accuracy'),
                                const SizedBox(width: 10),
                                _StatPill(value: '3 min', label: 'Quick'),
                                const SizedBox(width: 10),
                                _StatPill(value: '100%', label: 'Private'),
                              ],
                            ).animate().fadeIn(delay: 400.ms),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── White card panel ──────────────────────────────
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                    child: Column(
                      children: [

                        // ── Main Action Card ──────────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE91E8C).withValues(alpha: .1),
                                blurRadius: 20,
                                spreadRadius: 4,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Icon header
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFE91E8C),
                                      Color(0xFF7C4DFF)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFE91E8C)
                                          .withValues(alpha: .4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.favorite,
                                    color: Colors.white, size: 30),
                              ).animate()
                                  .scale(delay: 500.ms, duration: 600.ms, curve: Curves.elasticOut),

                              const SizedBox(height: 16),

                              const Text(
                                'Start Your Health Journey',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Join thousands of women taking\ncontrol of their health today.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    height: 1.5),
                              ),

                              const SizedBox(height: 22),

                              // Get Started
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/register'),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                    elevation: 0,
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFE91E8C),
                                          Color(0xFF7C4DFF)
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Create Free Account',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward,
                                              color: Colors.white, size: 18),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn(delay: 600.ms),

                              const SizedBox(height: 12),

                              // Sign In
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: OutlinedButton(
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/login'),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Color(0xFFE91E8C), width: 1.5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                  ),
                                  child: const Text(
                                    'Sign In to My Account',
                                    style: TextStyle(
                                      color: Color(0xFFE91E8C),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn(delay: 700.ms),
                            ],
                          ),
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                        const SizedBox(height: 24),

                        // ── Feature Cards Row ─────────────────────
                        Row(
                          children: [
                            _FeatureCard(
                              icon: Icons.shield_outlined,
                              iconColor: const Color(0xFF4CAF50),
                              title: 'Private\n& Secure',
                              subtitle: 'End-to-end encrypted',
                              delay: 700,
                            ),
                            const SizedBox(width: 10),
                            _FeatureCard(
                              icon: Icons.science_outlined,
                              iconColor: const Color(0xFFE91E8C),
                              title: 'Evidence\nBased',
                              subtitle: 'Medical research backed',
                              delay: 800,
                            ),
                            const SizedBox(width: 10),
                            _FeatureCard(
                              icon: Icons.speed_outlined,
                              iconColor: const Color(0xFF7C4DFF),
                              title: 'Quick\nResults',
                              subtitle: 'Under 3 minutes',
                              delay: 900,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ── How it works ──────────────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: .07),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'How It Works',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 14),
                              _HowItWorksStep(
                                number: '1',
                                title: 'Create your account',
                                subtitle: 'Sign up in seconds, completely free',
                                color: const Color(0xFFE91E8C),
                              ),
                              _HowItWorksStep(
                                number: '2',
                                title: 'Answer health questions',
                                subtitle: 'Simple 3-minute assessment form',
                                color: const Color(0xFF9C27B0),
                              ),
                              _HowItWorksStep(
                                number: '3',
                                title: 'Get your risk report',
                                subtitle:
                                    'Personalised results with recommendations',
                                color: const Color(0xFF7C4DFF),
                                isLast: true,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 900.ms),

                        const SizedBox(height: 24),

                        // ── Disclaimer ────────────────────────────
                        Column(
                          children: [
                            const Text(
                              'This app does not provide medical advice.\nAlways consult a qualified healthcare professional.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                  height: 1.6),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'Privacy Policy · Terms of Use',
                                style: TextStyle(
                                  color: Color(0xFFE91E8C),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 1000.ms),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Stat Pill ─────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  const _StatPill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .25)),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          Text(label,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}

// ── Feature Card ──────────────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final int delay;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: .07),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    height: 1.3)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 10, height: 1.4)),
          ],
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.2),
    );
  }
}

// ── How It Works Step ─────────────────────────────────────────────────────────

class _HowItWorksStep extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final Color color;
  final bool isLast;

  const _HowItWorksStep({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: .4)),
              ),
              child: Center(
                child: Text(number,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: color.withValues(alpha:0.2),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}