import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/app_settings.dart';
import '../core/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _dataBackupEnabled = true;
  bool _reminderEnabled = true;
  String _selectedFrequency = 'Weekly';

  bool get _darkModeEnabled => AppSettings.instance.isDarkMode;
  String get _selectedLanguage => AppSettings.instance.language.value;

  final List<String> _frequencies = ['Daily', 'Weekly', 'Monthly'];
  final List<String> _languages = [
    'English',
    'Swahili',
    'Luganda',
    'French',
    'Arabic',
  ];

  String _userName = '';
  String _userEmail = '';
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => _loadingUser = false);
        return;
      }
      await user.reload();
      final refreshed = FirebaseAuth.instance.currentUser;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!mounted) return;
      setState(() {
        _userName = doc.data()?['name'] ??
            refreshed?.displayName ??
            user.email?.split('@')[0] ??
            'User';
        _userEmail = refreshed?.email ?? user.email ?? '';
        _loadingUser = false;
      });
    } catch (_) {
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      setState(() {
        _userName =
            user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
        _userEmail = user?.email ?? '';
        _loadingUser = false;
      });
    }
  }

  String _freqLabel(String freq, AppTranslations l) {
    switch (freq) {
      case 'Daily':   return l.daily;
      case 'Weekly':  return l.weekly;
      case 'Monthly': return l.monthly;
      default:        return freq;
    }
  }

  // ── Send password reset email ─────────────────────────────────────────────
  Future<void> _sendPasswordResetEmail(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
          child: CircularProgressIndicator(color: Color(0xFFE91E8C))),
    );
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
      if (!mounted) return;
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [
            Icon(Icons.mark_email_read_outlined, color: Color(0xFFE91E8C)),
            SizedBox(width: 8),
            Text('Email Sent!'),
          ]),
          content: Text(
            'A password reset link has been sent to:\n\n${user.email}\n\n'
            'Open the email, click the link, set a new password, '
            'then sign in again.',
            style: const TextStyle(height: 1.6),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E8C)),
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? 'Failed to send reset email'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  // ── REAL Export Logic ──────────────────────────────────────────────────────
  Future<void> _exportData(BuildContext context, AppTranslations l) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(children: [
          const CircularProgressIndicator(color: Color(0xFFE91E8C)),
          const SizedBox(width: 16),
          Expanded(child: Text(l.exportingData)),
        ]),
      ),
    );

    try {
      // 1. Fetch user profile
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data();

      // 2. Fetch all assessments
      final assessmentsSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('assessments')
          .orderBy('createdAt', descending: false)
          .get();

      if (!mounted) return;
      Navigator.pop(context); // close progress

      if (assessmentsSnap.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.noDataToExport),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        return;
      }

      // 3. Build export content
      final now = DateTime.now();
      final buffer = StringBuffer();
      buffer.writeln('='.padRight(60, '='));
      buffer.writeln('  BREASTCARE AI — HEALTH DATA EXPORT');
      buffer.writeln('='.padRight(60, '='));
      buffer.writeln(
          'Exported: ${now.day}/${now.month}/${now.year} at ${now.hour}:${now.minute.toString().padLeft(2, '0')}');
      buffer.writeln();

      // User profile section
      buffer.writeln('USER PROFILE');
      buffer.writeln('-'.padRight(40, '-'));
      buffer.writeln('Name  : ${userData?['name'] ?? user.displayName ?? 'N/A'}');
      buffer.writeln('Email : ${user.email ?? 'N/A'}');
      buffer.writeln('UID   : ${user.uid}');
      buffer.writeln();

      // Summary counts
      final total = assessmentsSnap.docs.length;
      int lowCount = 0, modCount = 0, highCount = 0;
      for (final doc in assessmentsSnap.docs) {
        final risk = ((doc.data()['riskLevel'] as String?) ?? '').toLowerCase();
        if (risk.contains('low')) {
          lowCount++;
        } else if (risk.contains('high')) {
          highCount++;
        } else {
          modCount++;
        }
      }
      buffer.writeln('SUMMARY');
      buffer.writeln('-'.padRight(40, '-'));
      buffer.writeln('Total assessments : $total');
      buffer.writeln('Low risk          : $lowCount');
      buffer.writeln('Moderate risk     : $modCount');
      buffer.writeln('High risk         : $highCount');
      buffer.writeln();

      // Detailed records
      buffer.writeln('DETAILED RECORDS');
      buffer.writeln('-'.padRight(40, '-'));
      for (int i = 0; i < assessmentsSnap.docs.length; i++) {
        final data = assessmentsSnap.docs[i].data();
        final docId = assessmentsSnap.docs[i].id;

        String dateStr = 'Unknown';
        final rawDate = data['createdAt'];
        if (rawDate is Timestamp) {
          final dt = rawDate.toDate();
          dateStr =
              '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
        } else if (rawDate is String) {
          dateStr = rawDate;
        }

        buffer.writeln();
        buffer.writeln('--- Assessment #${i + 1}  ($dateStr) ---');
        buffer.writeln('  ID         : $docId');
        buffer.writeln('  Risk Level : ${data['riskLevel'] ?? 'N/A'}');
        buffer.writeln(
            '  Risk Score : ${data['riskScore'] != null ? '${(data['riskScore'] * 100).toStringAsFixed(1)}%' : 'N/A'}');

        final factors = data['riskFactors'];
        if (factors is Map) {
          buffer.writeln('  Risk Factors:');
          factors.forEach((k, v) => buffer.writeln('    - $k: $v'));
        }

        final answers = data['answers'];
        if (answers is Map) {
          buffer.writeln('  Answers:');
          answers.forEach((k, v) => buffer.writeln('    - $k: $v'));
        }

        final recs = data['recommendations'];
        if (recs is List && recs.isNotEmpty) {
          buffer.writeln('  Recommendations:');
          for (final r in recs) {
            buffer.writeln('    * $r');
          }
        }
      }

      buffer.writeln();
      buffer.writeln('='.padRight(60, '='));
      buffer.writeln('END OF EXPORT — BreastCare AI');
      buffer.writeln('This document contains confidential health information.');
      buffer.writeln('='.padRight(60, '='));

      // 4. Write temp file
      final dir = await getTemporaryDirectory();
      final fileName =
          'BreastCareAI_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.txt';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(buffer.toString());

      // 5. Share via system sheet
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/plain')],
        subject: 'BreastCare AI Health Data Export',
        text: 'My BreastCare AI health data — $total assessment records',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.exportSuccess),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } catch (e) {
      if (!mounted) return;
      try { Navigator.pop(context); } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.exportFailed),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(l.settings,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile ─────────────────────────────────────────
            _SectionHeader(title: l.profile).animate().fadeIn(),
            _SettingsCard(children: [
              _SettingsTile(
                icon: Icons.person_outline,
                iconColor: const Color(0xFFE91E8C),
                title: l.editProfile,
                subtitle: _loadingUser ? '…' : _userName,
                onTap: () => _showEditProfileDialog(context, l),
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.lock_outline,
                iconColor: const Color(0xFF7C4DFF),
                title: l.changePassword,
                subtitle: l.updatePassword,
                onTap: () => _showChangePasswordDialog(context, l),
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.email_outlined,
                iconColor: const Color(0xFF00BCD4),
                title: l.emailAddress,
                subtitle: _loadingUser ? '…' : _userEmail,
                onTap: () => _showChangeEmailDialog(context, l),
              ),
            ]).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 16),

            // ── Notifications ────────────────────────────────────
            _SectionHeader(title: l.notifications).animate().fadeIn(delay: 150.ms),
            _SettingsCard(children: [
              _SettingsToggle(
                icon: Icons.notifications_outlined,
                iconColor: const Color(0xFFFF9800),
                title: l.pushNotifications,
                subtitle: l.receiveHealthReminders,
                value: _notificationsEnabled,
                onChanged: (val) => setState(() => _notificationsEnabled = val),
              ),
              const Divider(height: 1, indent: 56),
              _SettingsToggle(
                icon: Icons.alarm_outlined,
                iconColor: const Color(0xFFE91E8C),
                title: l.selfExamReminders,
                subtitle: l.monthlyAlerts,
                value: _reminderEnabled,
                onChanged: (val) => setState(() => _reminderEnabled = val),
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.schedule_outlined,
                iconColor: const Color(0xFF4CAF50),
                title: l.reminderFrequency,
                subtitle: _freqLabel(_selectedFrequency, l),
                onTap: () => _showFrequencyPicker(context, l),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              ),
            ]).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            // ── Appearance ───────────────────────────────────────
            _SectionHeader(title: l.appearance).animate().fadeIn(delay: 250.ms),
            _SettingsCard(children: [
              _SettingsToggle(
                icon: Icons.dark_mode_outlined,
                iconColor: const Color(0xFF7C4DFF),
                title: l.darkMode,
                subtitle: l.switchDarkTheme,
                value: _darkModeEnabled,
                onChanged: (val) {
                  AppSettings.instance.setDarkMode(val);
                  setState(() {});
                },
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.language_outlined,
                iconColor: const Color(0xFF00BCD4),
                title: l.languageLabel,
                subtitle: _selectedLanguage,
                onTap: () => _showLanguagePicker(context, l),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              ),
            ]).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 16),

            // ── Security ─────────────────────────────────────────
            _SectionHeader(title: l.security).animate().fadeIn(delay: 350.ms),
            _SettingsCard(children: [
              _SettingsToggle(
                icon: Icons.fingerprint,
                iconColor: const Color(0xFF4CAF50),
                title: l.biometricLogin,
                subtitle: l.useFingerprint,
                value: _biometricEnabled,
                onChanged: (val) => setState(() => _biometricEnabled = val),
              ),
            ]).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 16),

            // ── Data & Privacy ───────────────────────────────────
            _SectionHeader(title: l.dataPrivacy).animate().fadeIn(delay: 450.ms),
            _SettingsCard(children: [
              _SettingsToggle(
                icon: Icons.cloud_upload_outlined,
                iconColor: const Color(0xFF00BCD4),
                title: l.cloudBackup,
                subtitle: l.autoSaveData,
                value: _dataBackupEnabled,
                onChanged: (val) => setState(() => _dataBackupEnabled = val),
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.download_outlined,
                iconColor: const Color(0xFF4CAF50),
                title: l.exportMyData,
                subtitle: l.downloadRecordsPdf,
                onTap: () => _showExportConfirmDialog(context, l),
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.delete_sweep_outlined,
                iconColor: Colors.orange,
                title: l.clearCache,
                subtitle: l.freeUpStorage,
                onTap: () => _showClearCacheDialog(context, l),
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                iconColor: const Color(0xFF7C4DFF),
                title: l.privacyPolicy,
                subtitle: l.howWeHandleData,
                onTap: () => _showPrivacyPolicy(context, l),
              ),
            ]).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 16),

            // ── About ────────────────────────────────────────────
            _SectionHeader(title: l.about).animate().fadeIn(delay: 550.ms),
            _SettingsCard(children: [
              _SettingsTile(
                icon: Icons.star_outline,
                iconColor: const Color(0xFFFF9800),
                title: l.rateApp,
                subtitle: l.shareFeedback,
                onTap: () => _showRateDialog(context, l),
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.help_outline,
                iconColor: const Color(0xFF4CAF50),
                title: l.helpSupport,
                subtitle: l.contactFaqs,
                onTap: () => _showSupportDialog(context, l),
              ),
            ]).animate().fadeIn(delay: 600.ms),

            const SizedBox(height: 16),

            // ── Sign Out ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showSignOutDialog(context, l),
                icon: const Icon(Icons.logout),
                label: Text(l.signOut),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ).animate().fadeIn(delay: 650.ms),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _showDeleteAccountDialog(context, l),
                child: Text(l.deleteAccount,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ),
            ).animate().fadeIn(delay: 700.ms),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Dialogs & Bottom Sheets
  // ══════════════════════════════════════════════════════════════════════════

  void _showChangePasswordDialog(BuildContext context, AppTranslations l) {
    final user = FirebaseAuth.instance.currentUser;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.lock_reset_outlined, color: Color(0xFF7C4DFF)),
          const SizedBox(width: 8),
          Text(l.changePasswordTitle),
        ]),
        content: Text(
          'We will send a password reset link to:\n\n${user?.email ?? ''}\n\n'
          'Click the link in the email to set your new password.',
          style: const TextStyle(height: 1.6),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF)),
            onPressed: () {
              Navigator.pop(context);
              _sendPasswordResetEmail(context);
            },
            child: Text(l.sendResetLink,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AppTranslations l) {
    final nameCtrl = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setS) {
          bool saving = false;
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(l.editProfile),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: l.fullName,
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFE91E8C), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    const Icon(Icons.email_outlined,
                        color: Colors.grey, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(_userEmail,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13))),
                  ]),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
              StatefulBuilder(
                builder: (_, setSave) => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E8C)),
                  onPressed: saving
                      ? null
                      : () async {
                          final newName = nameCtrl.text.trim();
                          if (newName.isEmpty) return;
                          setSave(() => saving = true);
                          try {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              await user.updateDisplayName(newName);
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .update({'name': newName});
                              if (mounted) setState(() => _userName = newName);
                            }
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(l.profileUpdated),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ));
                            }
                          } catch (_) {
                            setSave(() => saving = false);
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(l.save,
                          style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showChangeEmailDialog(BuildContext context, AppTranslations l) {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l.emailAddress),
        content: TextField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: l.newEmail,
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E8C)),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(l.verificationSent)));
            },
            child:
                Text(l.update, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── FIX: Frequency — ListView.builder, no overflow ────────────────────────
  void _showFrequencyPicker(BuildContext context, AppTranslations l) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.reminderFrequency,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _frequencies.length,
                itemBuilder: (_, i) {
                  final f = _frequencies[i];
                  return RadioListTile<String>(
                    value: f,
                    groupValue: _selectedFrequency,
                    activeColor: const Color(0xFFE91E8C),
                    title: Text(_freqLabel(f, l)),
                    onChanged: (val) {
                      setState(() => _selectedFrequency = val!);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── FIX: Language — ListView + isScrollControlled, no overflow ───────────
  void _showLanguagePicker(BuildContext context, AppTranslations l) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.language_outlined, color: Color(0xFF00BCD4)),
                const SizedBox(width: 8),
                Text(l.selectLanguage,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 4),
              const Text(
                'The entire app updates immediately',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Divider(height: 20),
              // Never overflows — shrinkWrap inside Column(mainAxisSize.min)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _languages.length,
                itemBuilder: (_, i) {
                  final lang = _languages[i];
                  final isSelected = lang == _selectedLanguage;
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      AppSettings.instance.setLanguage(lang);
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE91E8C).withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(
                                color: const Color(0xFFE91E8C), width: 1.5)
                            : null,
                      ),
                      child: Row(children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE91E8C)
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(_langEmoji(lang),
                              style: const TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(lang,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: isSelected
                                        ? const Color(0xFFE91E8C)
                                        : null,
                                  )),
                              Text(_nativeName(lang),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle,
                              color: Color(0xFFE91E8C), size: 20),
                      ]),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _langEmoji(String lang) {
    switch (lang) {
      case 'Swahili': return '🇹🇿';
      case 'Luganda': return '🇺🇬';
      case 'French':  return '🇫🇷';
      case 'Arabic':  return '🇸🇦';
      default:        return '🇬🇧';
    }
  }

  String _nativeName(String lang) {
    switch (lang) {
      case 'Swahili': return 'Kiswahili';
      case 'Luganda': return 'Oluganda';
      case 'French':  return 'Français';
      case 'Arabic':  return 'العربية';
      default:        return 'English';
    }
  }

  void _showExportConfirmDialog(BuildContext context, AppTranslations l) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.download_outlined, color: Color(0xFF4CAF50)),
          const SizedBox(width: 8),
          Text(l.exportMyData),
        ]),
        content: Text(
          '${l.downloadRecordsPdf}\n\n'
          'Your data will be saved as a text file. '
          'You can share it to email, Google Drive, or save locally.',
          style: const TextStyle(height: 1.6),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50)),
            onPressed: () {
              Navigator.pop(context);
              _exportData(context, l);
            },
            child: Text(l.exportMyData,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context, AppTranslations l) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l.clearCache),
        content:
            const Text('Temporary files will be cleared. Your data is safe.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(l.clearCache),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ));
            },
            child: Text(l.clearCache,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context, AppTranslations l) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(controller: controller, children: [
            Text(l.privacyPolicy,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              '${l.howWeHandleData}\n\n'
              '• Your assessment data is stored securely.\n'
              '• We never sell your personal data.\n'
              '• You can delete your data at any time.\n'
              '• We use Firebase for secure authentication.\n\n'
              'Contact: support@breastcareai.com',
              style: const TextStyle(height: 1.7, fontSize: 14),
            ),
          ]),
        ),
      ),
    );
  }

  void _showRateDialog(BuildContext context, AppTranslations l) {
    int stars = 5;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(l.rateApp),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How would you rate your experience?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setS(() => stars = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < stars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 28,
                    ),
                  ),
                )),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E8C)),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Thanks for $stars stars! ⭐')));
              },
              child: const Text('Submit',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ── FIX: Support — SafeArea + ListView, zero overflow risk ───────────────
  void _showSupportDialog(BuildContext context, AppTranslations l) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.helpSupport,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(l.contactFaqs,
                  style:
                      const TextStyle(fontSize: 13, color: Colors.grey)),
              const Divider(height: 20),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _SupportTile(
                    icon: Icons.email_outlined,
                    iconColor: const Color(0xFFE91E8C),
                    title: l.emailSupport,
                    subtitle: l.emailSupportAddr,
                    onTap: () => Navigator.pop(context),
                  ),
                  _SupportTile(
                    icon: Icons.question_answer_outlined,
                    iconColor: const Color(0xFF7C4DFF),
                    title: l.faqs,
                    subtitle: l.faqsSubtitle,
                    onTap: () => Navigator.pop(context),
                  ),
                  _SupportTile(
                    icon: Icons.bug_report_outlined,
                    iconColor: Colors.orange,
                    title: l.reportBug,
                    subtitle: l.reportBugSubtitle,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AppTranslations l) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l.signOut),
        content: Text(l.areYouSureSignOut),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            child: Text(l.signOut,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AppTranslations l) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l.deleteAccount,
            style: const TextStyle(color: Colors.red)),
        content: Text(l.deleteAccountWarning),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .delete();
                  await user.delete();
                }
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              } on FirebaseAuthException catch (e) {
                if (!mounted) return;
                if (e.code == 'requires-recent-login') {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        'Please sign in again to confirm account deletion'),
                    backgroundColor: Colors.orange,
                  ));
                }
              }
            },
            child: Text(l.deleteAccount,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Reusable Widgets
// ══════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
      );
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: .08),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(children: children),
      );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });
  @override
  Widget build(BuildContext context) => ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title,
            style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: trailing ??
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
        onTap: onTap,
      );
}

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SettingsToggle({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title,
            style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFE91E8C),
        ),
      );
}

class _SupportTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _SupportTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ]),
        ),
      );
}