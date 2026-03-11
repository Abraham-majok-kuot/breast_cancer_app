import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

class NewsletterScreen extends StatefulWidget {
  const NewsletterScreen({super.key});

  @override
  State<NewsletterScreen> createState() => _NewsletterScreenState();
}

class _NewsletterScreenState extends State<NewsletterScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final _emailController = TextEditingController();

  // ── Subscription state ────────────────────────────────────────
  bool _emailSubscribed     = false;
  bool _pushSubscribed      = false;
  bool _tipsPush            = true;
  bool _articlesPush        = true;
  bool _remindersPush       = false;
  bool _isLoading           = true;
  bool _isSaving            = false;

  // ── Article feed (pulled from Firestore) ─────────────────────
  List<Map<String, dynamic>> _articles = [];
  bool _loadingArticles = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadArticles();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ── Load saved preferences from Firestore ────────────────────
  Future<void> _loadPreferences() async {
    try {
      if (_user == null) return;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .get();

      final data = doc.data();
      if (!mounted) return;
      setState(() {
        _emailSubscribed  = data?['newsletter']?['emailSubscribed'] ?? false;
        _pushSubscribed   = data?['newsletter']?['pushSubscribed']  ?? false;
        _tipsPush         = data?['newsletter']?['tipsPush']        ?? true;
        _articlesPush     = data?['newsletter']?['articlesPush']    ?? true;
        _remindersPush    = data?['newsletter']?['remindersPush']   ?? false;

        final savedEmail  = data?['newsletter']?['email'] ?? '';
        _emailController.text = savedEmail.isNotEmpty
            ? savedEmail
            : (_user.email ?? '');
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _emailController.text = _user?.email ?? '';
        _isLoading = false;
      });
    }
  }

  // ── Load articles from Firestore ─────────────────────────────
  Future<void> _loadArticles() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('newsletter_articles')
          .orderBy('publishedAt', descending: true)
          .limit(10)
          .get();

      if (!mounted) return;

      if (snap.docs.isEmpty) {
        // Show default articles if Firestore collection is empty
        setState(() {
          _articles = _defaultArticles();
          _loadingArticles = false;
        });
        return;
      }

      setState(() {
        _articles = snap.docs.map((d) => {
          'title':       d['title'] ?? '',
          'summary':     d['summary'] ?? '',
          'category':    d['category'] ?? 'Tips',
          'readTime':    d['readTime'] ?? '3 min read',
          'publishedAt': d['publishedAt'],
        }).toList();
        _loadingArticles = false;
      });
    } catch (e) {
      setState(() {
        _articles = _defaultArticles();
        _loadingArticles = false;
      });
    }
  }

  // ── Save preferences to Firestore + handle FCM ───────────────
  Future<void> _savePreferences() async {
    if (_user == null) return;

    final email = _emailController.text.trim();
    if (_emailSubscribed && (email.isEmpty || !email.contains('@'))) {
      _showSnack('Please enter a valid email address', Colors.orange);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Handle push notification subscription via FCM
      if (_pushSubscribed) {
        await NotificationService.subscribe(
          tips:      _tipsPush,
          articles:  _articlesPush,
          reminders: _remindersPush,
        );
      } else {
        await NotificationService.unsubscribeAll();
      }

      // Save preferences to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .update({
        'newsletter': {
          'emailSubscribed': _emailSubscribed,
          'pushSubscribed':  _pushSubscribed,
          'email':           _emailSubscribed ? email : '',
          'tipsPush':        _tipsPush,
          'articlesPush':    _articlesPush,
          'remindersPush':   _remindersPush,
          'updatedAt':       FieldValue.serverTimestamp(),
        }
      });

      // If email subscribed, also save to newsletter_subscribers collection
      // (used by Firebase Extension to send emails)
      if (_emailSubscribed && email.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('newsletter_subscribers')
            .doc(_user.uid)
            .set({
          'email':     email,
          'name':      _user.displayName ?? '',
          'uid':       _user.uid,
          'topics':    ['awareness_tips', 'health_articles'],
          'active':    true,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        // Unsubscribe — mark inactive
        await FirebaseFirestore.instance
            .collection('newsletter_subscribers')
            .doc(_user.uid)
            .set({'active': false}, SetOptions(merge: true));
      }

      setState(() => _isSaving = false);
      _showSnack('Preferences saved successfully!', Colors.green);
    } catch (e) {
      setState(() => _isSaving = false);
      _showSnack('Failed to save. Try again.', Colors.red);
    }
  }

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Default articles when Firestore is empty ─────────────────
  List<Map<String, dynamic>> _defaultArticles() => [
    {
      'title': 'Understanding Your Breast Cancer Risk Factors',
      'summary': 'Learn how age, family history, lifestyle, and hormonal factors '
          'contribute to breast cancer risk and what you can do today.',
      'category': 'Awareness',
      'readTime': '5 min read',
    },
    {
      'title': 'The Power of Monthly Self-Examination',
      'summary': 'Regular breast self-exams are one of the most effective tools '
          'for early detection. Here is a step-by-step guide.',
      'category': 'Tips',
      'readTime': '4 min read',
    },
    {
      'title': 'How Exercise Reduces Breast Cancer Risk',
      'summary': 'Research shows 150 minutes of moderate exercise per week can '
          'reduce breast cancer risk by up to 20%. Find out why.',
      'category': 'Health',
      'readTime': '3 min read',
    },
    {
      'title': 'Nutrition and Breast Cancer Prevention',
      'summary': 'A Mediterranean-style diet rich in vegetables, fruits, and '
          'whole grains is associated with lower breast cancer incidence.',
      'category': 'Health',
      'readTime': '6 min read',
    },
    {
      'title': 'When Should You Get a Mammogram?',
      'summary': 'Guidelines vary — we break down the recommendations by age '
          'and risk level so you know exactly when to book your screening.',
      'category': 'Awareness',
      'readTime': '4 min read',
    },
    {
      'title': 'Alcohol and Breast Cancer: What the Research Says',
      'summary': 'Even moderate alcohol consumption increases risk. Understand '
          'the science and make informed choices about your health.',
      'category': 'Tips',
      'readTime': '3 min read',
    },
  ];

  // ── Category colour helper ────────────────────────────────────
  Color _categoryColor(String category) {
    switch (category) {
      case 'Awareness': return const Color(0xFFE91E8C);
      case 'Tips':      return const Color(0xFF7C4DFF);
      case 'Health':    return const Color(0xFF4CAF50);
      default:          return const Color(0xFF00BCD4);
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Newsletter & Updates',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE91E8C)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Hero banner ───────────────────────────────
                  _heroBanner().animate().fadeIn().slideY(begin: -0.1),
                  const SizedBox(height: 24),

                  // ── Email subscription card ───────────────────
                  _sectionTitle('📧 Email Newsletter'),
                  const SizedBox(height: 12),
                  _emailCard().animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 24),

                  // ── Push notifications card ───────────────────
                  _sectionTitle('🔔 Push Notifications'),
                  const SizedBox(height: 12),
                  _pushCard().animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 24),

                  // ── Save button ───────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _savePreferences,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E8C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Save Preferences',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 32),

                  // ── Latest articles feed ──────────────────────
                  _sectionTitle('📰 Latest Articles'),
                  const SizedBox(height: 12),
                  _loadingArticles
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFE91E8C)))
                      : Column(
                          children: _articles.asMap().entries.map((entry) {
                            return _articleCard(entry.value, entry.key)
                                .animate()
                                .fadeIn(delay: Duration(milliseconds: 100 * entry.key))
                                .slideX(begin: 0.1);
                          }).toList(),
                        ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // ── Hero banner widget ────────────────────────────────────────
  Widget _heroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E8C), Color(0xFF7C4DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Stay Informed,',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 13)),
                const Text('Stay Healthy',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  'Get breast cancer awareness tips and\n'
                  'health articles delivered to you.',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.campaign_outlined,
                color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  // ── Email subscription card ───────────────────────────────────
  Widget _emailCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: .08), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle row
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E8C).withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.email_outlined,
                    color: Color(0xFFE91E8C), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email Newsletter',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('Awareness tips & health articles',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Switch(
                value: _emailSubscribed,
                activeColor: const Color(0xFFE91E8C),
                onChanged: (v) => setState(() => _emailSubscribed = v),
              ),
            ],
          ),

          // Email input (visible when subscribed)
          if (_emailSubscribed) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Your email address',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'example@email.com',
                prefixIcon: const Icon(Icons.email_outlined,
                    color: Color(0xFFE91E8C)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFFE91E8C), width: 2)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 10),
            // What they will receive
            _infoChips(['Awareness Tips', 'Health Articles', 'Monthly Digest']),
          ],
        ],
      ),
    );
  }

  // ── Push notification card ────────────────────────────────────
  Widget _pushCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: .08), blurRadius: 8)
        ],
      ),
      child: Column(
        children: [
          // Main toggle
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications_outlined,
                    color: Color(0xFF7C4DFF), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Push Notifications',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('Receive alerts on your phone',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Switch(
                value: _pushSubscribed,
                activeColor: const Color(0xFF7C4DFF),
                onChanged: (v) => setState(() => _pushSubscribed = v),
              ),
            ],
          ),

          // Sub-toggles (visible when push is on)
          if (_pushSubscribed) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Notify me about:',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54)),
            ),
            const SizedBox(height: 8),
            _pushToggleRow(
              icon: Icons.lightbulb_outline,
              color: const Color(0xFFE91E8C),
              label: 'Breast Cancer Awareness Tips',
              subtitle: 'Weekly tips to reduce your risk',
              value: _tipsPush,
              onChanged: (v) => setState(() => _tipsPush = v),
            ),
            _pushToggleRow(
              icon: Icons.article_outlined,
              color: const Color(0xFF00BCD4),
              label: 'Health Articles & News',
              subtitle: 'Latest research and health news',
              value: _articlesPush,
              onChanged: (v) => setState(() => _articlesPush = v),
            ),
            _pushToggleRow(
              icon: Icons.alarm_outlined,
              color: const Color(0xFF4CAF50),
              label: 'Assessment Reminders',
              subtitle: 'Monthly reminder to check your risk',
              value: _remindersPush,
              onChanged: (v) => setState(() => _remindersPush = v),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pushToggleRow({
    required IconData icon,
    required Color color,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: color,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ── Article card widget ───────────────────────────────────────
  Widget _articleCard(Map<String, dynamic> article, int index) {
    final color = _categoryColor(article['category'] ?? 'Tips');
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha:.08), blurRadius: 8)
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showArticleDetail(article),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category icon
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  article['category'] == 'Awareness'
                      ? Icons.favorite_outline
                      : article['category'] == 'Tips'
                          ? Icons.lightbulb_outline
                          : Icons.local_hospital_outlined,
                  color: color, size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha:.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(article['category'] ?? 'Tips',
                          style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 6),
                    Text(article['title'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            height: 1.3)),
                    const SizedBox(height: 4),
                    Text(article['summary'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            height: 1.4)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(article['readTime'] ?? '3 min read',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                        const Spacer(),
                        Text('Read more →',
                            style: TextStyle(
                                fontSize: 11,
                                color: color,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Article detail bottom sheet ───────────────────────────────
  void _showArticleDetail(Map<String, dynamic> article) {
    final color = _categoryColor(article['category'] ?? 'Tips');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(article['category'] ?? '',
                    style: TextStyle(
                        color: color, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              Text(article['title'] ?? '',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold,
                      height: 1.3)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(article['readTime'] ?? '',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(article['summary'] ?? '',
                  style: const TextStyle(
                      fontSize: 15, height: 1.7, color: Colors.black87)),
              const SizedBox(height: 20),
              // Placeholder body
              const Text(
                'This content is provided for awareness purposes. '
                'Always consult a qualified healthcare professional '
                'for medical advice, diagnosis, or treatment. '
                'Early detection significantly improves breast cancer '
                'outcomes — regular screening and self-examination '
                'are key components of preventive healthcare.',
                style: TextStyle(
                    fontSize: 14, height: 1.7, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side: BorderSide(color: color),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87));

  Widget _infoChips(List<String> labels) => Wrap(
        spacing: 8,
        children: labels.map((l) => Chip(
          label: Text(l,
              style: const TextStyle(fontSize: 11, color: Color(0xFFE91E8C))),
          backgroundColor: const Color(0xFFE91E8C).withValues(alpha:0.08),
          side: BorderSide(color: const Color(0xFFE91E8C).withValues(alpha:.3)),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        )).toList(),
      );
}