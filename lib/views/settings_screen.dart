import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_settings.dart';
import '../core/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ── Toggle states ──────────────────────────────────────────────────────────
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _dataBackupEnabled = true;
  bool _reminderEnabled = true;
  String _selectedFrequency = 'Weekly';

  // Theme & language are sourced from AppSettings
  bool get _darkModeEnabled => AppSettings.instance.isDarkMode;
  String get _selectedLanguage => AppSettings.instance.language.value;

  final List<String> _frequencies = ['Daily', 'Weekly', 'Monthly'];
  final List<String> _languages = ['English', 'Swahili', 'French', 'Arabic'];

  // ── User data loaded from Firebase ────────────────────────────────────────
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

  // ── Helper: display translated frequency ──────────────────────────────────
  String _freqLabel(String freq, AppTranslations l) {
    switch (freq) {
      case 'Daily':
        return l.daily;
      case 'Weekly':
        return l.weekly;
      case 'Monthly':
        return l.monthly;
      default:
        return freq;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
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

            // ── Profile ───────────────────────────────────────────
            _SectionHeader(title: l.profile).animate().fadeIn(),

            _SettingsCard(
              children: [
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
                  onTap: () => Navigator.pushNamed(context, '/reset-password'),
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.email_outlined,
                  iconColor: const Color(0xFF00BCD4),
                  title: l.emailAddress,
                  subtitle: _loadingUser ? '…' : _userEmail,
                  onTap: () => _showChangeEmailDialog(context, l),
                ),
              ],
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 16),

            // ── Notifications ─────────────────────────────────────
            _SectionHeader(title: l.notifications)
                .animate()
                .fadeIn(delay: 150.ms),

            _SettingsCard(
              children: [
                _SettingsToggle(
                  icon: Icons.notifications_outlined,
                  iconColor: const Color(0xFFFF9800),
                  title: l.pushNotifications,
                  subtitle: l.receiveHealthReminders,
                  value: _notificationsEnabled,
                  onChanged: (val) =>
                      setState(() => _notificationsEnabled = val),
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
              ],
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            // ── Appearance ────────────────────────────────────────
            _SectionHeader(title: l.appearance)
                .animate()
                .fadeIn(delay: 250.ms),

            _SettingsCard(
              children: [
                _SettingsToggle(
                  icon: Icons.dark_mode_outlined,
                  iconColor: const Color(0xFF7C4DFF),
                  title: l.darkMode,
                  subtitle: l.switchDarkTheme,
                  value: _darkModeEnabled,
                  onChanged: (val) {
                    AppSettings.instance.setDarkMode(val);
                    setState(() {}); // refresh the toggle visual
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
              ],
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 16),

            // ── Security ──────────────────────────────────────────
            _SectionHeader(title: l.security).animate().fadeIn(delay: 350.ms),

            _SettingsCard(
              children: [
                _SettingsToggle(
                  icon: Icons.fingerprint,
                  iconColor: const Color(0xFF4CAF50),
                  title: l.biometricLogin,
                  subtitle: l.useFingerprint,
                  value: _biometricEnabled,
                  onChanged: (val) => setState(() => _biometricEnabled = val),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 16),

            // ── Data & Privacy ────────────────────────────────────
            _SectionHeader(title: l.dataPrivacy)
                .animate()
                .fadeIn(delay: 450.ms),

            _SettingsCard(
              children: [
                _SettingsToggle(
                  icon: Icons.cloud_upload_outlined,
                  iconColor: const Color(0xFF00BCD4),
                  title: l.cloudBackup,
                  subtitle: l.autoSaveData,
                  value: _dataBackupEnabled,
                  onChanged: (val) =>
                      setState(() => _dataBackupEnabled = val),
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.download_outlined,
                  iconColor: const Color(0xFF4CAF50),
                  title: l.exportMyData,
                  subtitle: l.downloadRecordsPdf,
                  onTap: () => _showExportDialog(context, l),
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
                  onTap: () => _showPrivacyPolicy(context),
                ),
              ],
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 16),

            // ── About (App Version removed) ───────────────────────
            _SectionHeader(title: l.about).animate().fadeIn(delay: 550.ms),

            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.star_outline,
                  iconColor: const Color(0xFFFF9800),
                  title: l.rateApp,
                  subtitle: l.shareFeedback,
                  onTap: () => _showRateDialog(context),
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.help_outline,
                  iconColor: const Color(0xFF4CAF50),
                  title: l.helpSupport,
                  subtitle: l.contactFaqs,
                  onTap: () => _showSupportDialog(context),
                ),
              ],
            ).animate().fadeIn(delay: 600.ms),

            const SizedBox(height: 16),

            // ── Sign Out ──────────────────────────────────────────
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
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 650.ms),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _showDeleteAccountDialog(context, l),
                child: Text(
                  l.deleteAccount,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            ).animate().fadeIn(delay: 700.ms),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  /// Edit Profile – pre-fills with current Firebase data and saves back.
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
                // Name field pre-filled from Firebase
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
                      borderSide: const BorderSide(
                          color: Color(0xFFE91E8C), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Email shown read-only
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.email_outlined,
                          color: Colors.grey, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _userEmail,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                child: Text(l.cancel),
              ),
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
                            final user =
                                FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              await user.updateDisplayName(newName);
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .update({'name': newName});
                              if (mounted) {
                                setState(() => _userName = newName);
                              }
                            }
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l.profileUpdated),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                ),
                              );
                            }
                          } catch (_) {
                            setSave(() => saving = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to update profile'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
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
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E8C)),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.verificationSent)),
              );
            },
            child: Text(l.update,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFrequencyPicker(BuildContext context, AppTranslations l) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.reminderFrequency,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._frequencies.map((f) => ListTile(
                  title: Text(_freqLabel(f, l)),
                  leading: Radio<String>(
                    value: f,
                    groupValue: _selectedFrequency,
                    activeColor: const Color(0xFFE91E8C),
                    onChanged: (val) {
                      setState(() => _selectedFrequency = val!);
                      Navigator.pop(context);
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, AppTranslations l) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.selectLanguage,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._languages.map((lang) => ListTile(
                  title: Text(lang),
                  subtitle: Text(_nativeName(lang),
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey)),
                  leading: Radio<String>(
                    value: lang,
                    groupValue: _selectedLanguage,
                    activeColor: const Color(0xFFE91E8C),
                    onChanged: (val) {
                      AppSettings.instance.setLanguage(val!);
                      setState(() {}); // refresh subtitle
                      Navigator.pop(context);
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }

  /// Returns the native name of a language for display in the picker.
  String _nativeName(String lang) {
    switch (lang) {
      case 'Swahili':
        return 'Kiswahili';
      case 'French':
        return 'Français';
      case 'Arabic':
        return 'العربية';
      default:
        return 'English';
    }
  }

  void _showExportDialog(BuildContext context, AppTranslations l) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l.exportMyData),
        content: Text(l.downloadRecordsPdf),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50)),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Export started — check your downloads')),
              );
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
            const Text('This will clear temporary files. Your data will not be deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.cancel)),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: Text(l.clearCache,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: controller,
            children: const [
              Text('Privacy Policy',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text(
                'BreastCare AI takes your privacy seriously. We collect only the minimum data needed to provide our health assessment service.\n\n'
                '• Your assessment data is stored securely and encrypted.\n'
                '• We never sell your personal data to third parties.\n'
                '• You can delete your data at any time.\n'
                '• We use Firebase for secure authentication and data storage.\n\n'
                'For questions, contact: support@breastcareai.com',
                style: TextStyle(height: 1.6, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRateDialog(BuildContext context) {
    int stars = 5;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text(context.l.rateApp),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How would you rate your experience?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    5,
                    (i) => IconButton(
                          icon: Icon(
                            i < stars ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () => setS(() => stars = i + 1),
                        )),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(context.l.cancel)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E8C)),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Thanks for rating us $stars stars! ⭐')),
                );
              },
              child: const Text('Submit',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l.helpSupport,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email_outlined,
                  color: Color(0xFFE91E8C)),
              title: const Text('Email Support'),
              subtitle: const Text('support@breastcareai.com'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.question_answer_outlined,
                  color: Color(0xFF7C4DFF)),
              title: const Text('FAQs'),
              subtitle: const Text('Common questions answered'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading:
                  const Icon(Icons.bug_report_outlined, color: Colors.orange),
              title: const Text('Report a Bug'),
              subtitle: const Text('Help us improve the app'),
              onTap: () => Navigator.pop(context),
            ),
          ],
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
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.cancel)),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
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
        content: const Text(
            'This will permanently delete your account and all data. This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.cancel)),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            child: Text(l.deleteAccount,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Widgets ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha :0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing:
          trailing ?? const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
      onTap: onTap,
    );
  }
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
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFE91E8C),
      ),
    );
  }
}
