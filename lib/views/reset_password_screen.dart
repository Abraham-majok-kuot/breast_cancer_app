import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;
  bool _isLoading = false;
  bool _passwordChanged = false;

  // Password strength state
  double _strength = 0;
  String _strengthLabel = '';
  Color _strengthColor = Colors.red;

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _checkStrength(String value) {
    double strength = 0;
    if (value.length >= 8) strength += 0.25;
    if (value.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (value.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) strength += 0.25;

    String label;
    Color color;
    if (strength <= 0.25) {
      label = 'Weak';
      color = Colors.red;
    } else if (strength <= 0.5) {
      label = 'Fair';
      color = Colors.orange;
    } else if (strength <= 0.75) {
      label = 'Good';
      color = Colors.yellow.shade700;
    } else {
      label = 'Strong';
      color = Colors.green;
    }

    setState(() {
      _strength = strength;
      _strengthLabel = label;
      _strengthColor = color;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _passwordChanged = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Change Password',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _passwordChanged
              ? _buildSuccessView(context)
              : _buildFormView(context, theme),
        ),
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_outline,
              size: 56, color: Colors.green),
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        const Text(
          'Password Changed!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 12),
        const Text(
          'Your password has been updated successfully.\nPlease use your new password next time you sign in.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, height: 1.6),
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E8C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Back to Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }

  Widget _buildFormView(BuildContext context, ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE91E8C).withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_reset_outlined,
                  size: 40, color: Color(0xFFE91E8C)),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          ),

          const SizedBox(height: 20),

          Center(
            child: Text(
              'Create a strong password',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const Center(
            child: Text(
              'Your new password must be different\nfrom your previous password.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
          ),

          const SizedBox(height: 32),

          // Requirements card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE91E8C).withValues(alpha:.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFFE91E8C).withValues(alpha:.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Password Requirements:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                SizedBox(height: 8),
                _RequirementItem(text: 'At least 8 characters'),
                _RequirementItem(text: 'One uppercase letter (A-Z)'),
                _RequirementItem(text: 'One number (0-9)'),
                _RequirementItem(text: 'One special character (!@#\$)'),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 24),

          // Current password
          _buildPasswordField(
            controller: _currentPasswordCtrl,
            label: 'Current Password',
            hint: 'Enter your current password',
            obscure: _hideCurrentPassword,
            onToggle: () =>
                setState(() => _hideCurrentPassword = !_hideCurrentPassword),
            validator: (v) =>
                v == null || v.isEmpty ? 'Enter your current password' : null,
            delay: 150,
          ),

          const SizedBox(height: 16),

          // New password
          _buildPasswordField(
            controller: _newPasswordCtrl,
            label: 'New Password',
            hint: 'Enter your new password',
            obscure: _hideNewPassword,
            onToggle: () =>
                setState(() => _hideNewPassword = !_hideNewPassword),
            onChanged: _checkStrength,
            validator: (v) {
              if (v == null || v.length < 8) return 'Minimum 8 characters';
              if (!v.contains(RegExp(r'[A-Z]'))) {
                return 'Add at least one uppercase letter';
              }
              if (!v.contains(RegExp(r'[0-9]'))) {
                return 'Add at least one number';
              }
              return null;
            },
            delay: 200,
          ),

          // Strength bar
          if (_newPasswordCtrl.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _strength,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(_strengthColor),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _strengthLabel,
                  style: TextStyle(
                      color: _strengthColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Confirm password
          _buildPasswordField(
            controller: _confirmPasswordCtrl,
            label: 'Confirm New Password',
            hint: 'Re-enter your new password',
            obscure: _hideConfirmPassword,
            onToggle: () => setState(
                () => _hideConfirmPassword = !_hideConfirmPassword),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != _newPasswordCtrl.text) return 'Passwords do not match';
              return null;
            },
            delay: 250,
          ),

          const SizedBox(height: 32),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E8C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Update Password',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 16),

          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    required int delay,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFE91E8C)),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE91E8C), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
    ).animate().fadeIn(delay: Duration(milliseconds: delay));
  }
}

class _RequirementItem extends StatelessWidget {
  final String text;
  const _RequirementItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              size: 14, color: Color(0xFFE91E8C)),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }
}