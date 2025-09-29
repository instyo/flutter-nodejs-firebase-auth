import 'package:auth_test/core/firebase_service.dart';
import 'package:auth_test/core/get_storage.dart';
import 'package:flutter/material.dart';

class EmailValidationScreen extends StatefulWidget {
  const EmailValidationScreen({super.key});

  static void open(BuildContext context, String email) {
    Navigator.pushReplacementNamed(
      context,
      '/validate-email',
      arguments: email,
    );
  }

  @override
  State<EmailValidationScreen> createState() => _EmailValidationScreenState();
}

class _EmailValidationScreenState extends State<EmailValidationScreen> {
  bool _isEmailVerified = false;
  bool _isResending = false;
  int _resendCountdown = 0;

  void _resendEmail() async {
    if (_resendCountdown > 0) return;

    setState(() {
      _isResending = true;
      _resendCountdown = 60;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isResending = false;
    });

    // Start countdown
    _startCountdown();

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent successfully!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_resendCountdown > 0 && mounted) {
        setState(() {
          _resendCountdown--;
        });
        _startCountdown();
      }
    });
  }

  Future<void> checkEmailVerification() async {}

  void _checkEmailVerification() async {
    final isEmailVerified = await FirebaseService().isEmailVerified(
      AuthStorage.getAuthData()?.uid ?? '',
    );

    if (isEmailVerified) {
      // For demo purposes, randomly verify after checking
      setState(() {
        _isEmailVerified = true;
      });

      final authData = AuthStorage.getAuthData()?.copyWith(emailVerified: true);
      await AuthStorage.saveAuthData(authData?.toJson() ?? {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );

        // Navigate to main app after delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            // In a real app, this would navigate to the main app screen
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/onboard',
              (route) => false,
            );
          }
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email is NOT verified!'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Email Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF4FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isEmailVerified
                        ? Icons.mark_email_read
                        : Icons.email_outlined,
                    size: 60,
                    color: _isEmailVerified
                        ? const Color(0xFF10B981)
                        : const Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                Text(
                  _isEmailVerified ? 'Email Verified!' : 'Check Your Email',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Description
                Text(
                  _isEmailVerified
                      ? 'Great! Your email has been verified successfully. You can now access the app.'
                      : 'We\'ve sent a verification link to $email. Please check your email and click the verification link to continue.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                if (!_isEmailVerified) ...[
                  // Check Email Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _checkEmailVerification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'I\'ve Verified My Email',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Resend Email Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _resendCountdown > 0 ? null : _resendEmail,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _resendCountdown > 0
                              ? const Color(0xFFD1D5DB)
                              : const Color(0xFF2563EB),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isResending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF2563EB),
                                ),
                              ),
                            )
                          : Text(
                              _resendCountdown > 0
                                  ? 'Resend in ${_resendCountdown}s'
                                  : 'Resend Email',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _resendCountdown > 0
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF2563EB),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tips Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: const Color(0xFFF59E0B),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Tips',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '• Check your spam or junk folder\n• Make sure you entered the correct email\n• The link expires in 24 hours',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Back to Login
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
