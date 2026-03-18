import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  String _displayName = '';
  String? _photoUrl;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      if (_user == null) return;
      await _user.reload();
      final refreshed = FirebaseAuth.instance.currentUser;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .get();
      if (!mounted) return;
      setState(() {
        _displayName = doc.data()?['name'] ??
            refreshed?.displayName ??
            _user.email?.split('@')[0] ??
            'User';
        _photoUrl = doc.data()?['photoUrl'] ?? refreshed?.photoURL;
      });
    } catch (e) {
      setState(() {
        _displayName = _user?.displayName ??
            _user?.email?.split('@')[0] ??
            'User';
        _photoUrl = _user?.photoURL;
      });
    }
  }

  Future<void> _changeProfilePhoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Update Profile Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E8C).withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt_outlined,
                    color: Color(0xFFE91E8C)),
              ),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library_outlined,
                    color: Color(0xFF7C4DFF)),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_photoUrl != null)
              ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.red),
                ),
                title: const Text('Remove Photo',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _removePhoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 40,
        maxWidth: 200,
        maxHeight: 200,
      );
      if (picked == null) return;
      setState(() => _uploadingPhoto = true);
      final file = File(picked.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('${_user!.uid}.jpg');
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      await ref.putFile(file, metadata);
      final downloadUrl = await ref.getDownloadURL();
      await _user.updatePhotoURL(downloadUrl);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .update({'photoUrl': downloadUrl});
      setState(() {
        _photoUrl = downloadUrl;
        _uploadingPhoto = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Profile photo updated!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } catch (e) {
      setState(() => _uploadingPhoto = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Failed to update photo. Try again.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  Future<void> _removePhoto() async {
    try {
      setState(() => _uploadingPhoto = true);
      await _user!.updatePhotoURL(null);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .update({'photoUrl': FieldValue.delete()});
      setState(() {
        _photoUrl = null;
        _uploadingPhoto = false;
      });
    } catch (e) {
      setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _exportData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Row(children: [
          CircularProgressIndicator(color: Color(0xFFE91E8C)),
          SizedBox(width: 16),
          Expanded(child: Text('Exporting your data…')),
        ]),
      ),
    );

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users').doc(user.uid).get();
      final assessmentsSnap = await FirebaseFirestore.instance
          .collection('users').doc(user.uid)
          .collection('assessments')
          .orderBy('createdAt', descending: false)
          .get();

      if (!mounted) return;
      Navigator.pop(context);

      if (assessmentsSnap.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No assessment data to export yet.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ));
        return;
      }

      final now = DateTime.now();
      final buffer = StringBuffer();
      buffer.writeln('='.padRight(60, '='));
      buffer.writeln('  BREASTCARE AI — HEALTH DATA EXPORT');
      buffer.writeln('='.padRight(60, '='));
      buffer.writeln('Exported: ${now.day}/${now.month}/${now.year}');
      buffer.writeln();
      buffer.writeln('USER PROFILE');
      buffer.writeln('-'.padRight(40, '-'));
      buffer.writeln('Name  : ${userDoc.data()?['name'] ?? user.displayName ?? 'N/A'}');
      buffer.writeln('Email : ${user.email ?? 'N/A'}');
      buffer.writeln();

      final total = assessmentsSnap.docs.length;
      int low = 0, mod = 0, high = 0;
      for (final doc in assessmentsSnap.docs) {
        final risk = ((doc.data()['riskLevel'] as String?) ?? '').toLowerCase();
        if (risk.contains('low')) low++;
        else if (risk.contains('high')) high++;
        else mod++;
      }
      buffer.writeln('SUMMARY');
      buffer.writeln('-'.padRight(40, '-'));
      buffer.writeln('Total: $total  |  Low: $low  |  Moderate: $mod  |  High: $high');
      buffer.writeln();
      buffer.writeln('DETAILED RECORDS');
      buffer.writeln('-'.padRight(40, '-'));

      for (int i = 0; i < assessmentsSnap.docs.length; i++) {
        final data = assessmentsSnap.docs[i].data();
        String dateStr = 'Unknown';
        final rawDate = data['createdAt'];
        if (rawDate is Timestamp) {
          final dt = rawDate.toDate();
          dateStr = '${dt.day}/${dt.month}/${dt.year}';
        }
        buffer.writeln();
        buffer.writeln('Assessment #${i + 1}  ($dateStr)');
        buffer.writeln('  Risk Level : ${data['riskLevel'] ?? 'N/A'}');
        buffer.writeln('  Risk Score : ${data['riskScore'] != null ? '${(data['riskScore'] * 100).toStringAsFixed(1)}%' : 'N/A'}');
      }

      buffer.writeln();
      buffer.writeln('='.padRight(60, '='));
      buffer.writeln('END OF EXPORT — BreastCare AI');
      buffer.writeln('='.padRight(60, '='));

      final dir = await getTemporaryDirectory();
      final fileName = 'BreastCareAI_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.txt';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(buffer.toString());

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/plain')],
        subject: 'BreastCare AI Health Data Export',
        text: 'My BreastCare AI health data — $total assessment records',
      );
    } catch (e) {
      if (!mounted) return;
      try { Navigator.pop(context); } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Export failed. Please try again.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    if (hour < 21) return 'Good Evening 🌆';
    return 'Good Night 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l;
    final screenWidth = MediaQuery.of(context).size.width;
    final firstName = _displayName.split(' ').first;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE91E8C), Color(0xFF7C4DFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Top Bar ──────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l.hello}, $firstName 👋',
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(color: Colors.white70),
                          ),
                          Text(
                            _timeGreeting(),
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        // Newsletter bell — top bar only, removed from grid
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/newsletter'),
                          child: Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.notifications_outlined,
                                color: Colors.white, size: 22),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Settings icon — top bar only, removed from grid
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/settings'),
                          child: Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.settings_outlined,
                                color: Colors.white, size: 22),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Profile avatar
                        GestureDetector(
                          onTap: _changeProfilePhoto,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                                backgroundImage: _photoUrl != null
                                    ? NetworkImage(_photoUrl!)
                                    : null,
                                child: _uploadingPhoto
                                    ? const SizedBox(
                                        width: 20, height: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2))
                                    : _photoUrl == null
                                        ? Text(
                                            firstName.isNotEmpty
                                                ? firstName[0].toUpperCase()
                                                : 'U',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18))
                                        : null,
                              ),
                              Positioned(
                                bottom: 0, right: 0,
                                child: Container(
                                  width: 16, height: 16,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.camera_alt,
                                      size: 10, color: Color(0xFFE91E8C)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ).animate().fadeIn().slideY(begin: -0.2),

                const SizedBox(height: 32),

                // ── Hero Card ─────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite,
                          color: Colors.white, size: 56),
                      const SizedBox(height: 16),
                      Text(
                        l.yourHealthJourney,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.earlyAwareness,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.white70, height: 1.6),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/input'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFE91E8C),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(l.startAssessment,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                const SizedBox(height: 12),

                // ── Export Data button ────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _exportData(),
                    icon: const Icon(Icons.download_outlined,
                        color: Colors.white, size: 18),
                    label: const Text('Export My Data',
                        style: TextStyle(color: Colors.white, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ).animate().fadeIn(delay: 250.ms),

                const SizedBox(height: 28),

                // ── Quick Actions ─────────────────────────────────────────
                // Newsletter → bell icon top bar only
                // Settings  → gear icon top bar only
                // No duplicates, no redundancies
                Text(l.quickActions,
                    style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 16),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: screenWidth < 360 ? 1.1 : 1.3,
                  children: [
                    _ActionCard(
                      icon: Icons.health_and_safety_outlined,
                      label: l.newAssessment,
                      color: Colors.pinkAccent,
                      onTap: () => Navigator.pushNamed(context, '/input'),
                    ),
                    _ActionCard(
                      icon: Icons.history_outlined,
                      label: l.viewHistory,
                      color: const Color(0xFF7C4DFF),
                      onTap: () => Navigator.pushNamed(context, '/history'),
                    ),
                    _ActionCard(
                      icon: Icons.analytics_outlined,
                      label: 'Analytics',
                      color: const Color(0xFF4CAF50),
                      onTap: () => Navigator.pushNamed(context, '/analytics'),
                    ),
                    _ActionCard(
                      icon: Icons.menu_book_outlined,
                      label: l.educationHub,
                      color: const Color(0xFF00BCD4),
                      onTap: () => Navigator.pushNamed(context, '/education'),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),


                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reusable Widgets ──────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.25),
                  shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 19),
            ),
            const SizedBox(height: 7),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    height: 1.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final String tip;
  final int delay;
  final VoidCallback onTap;
  const _TipCard({
    required this.icon,
    required this.tip,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .15),
                  shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(tip,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13, height: 1.5))),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white38, size: 14),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideX(begin: 0.2);
  }
}

class _BottomLinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _BottomLinkButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Flexible(
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}