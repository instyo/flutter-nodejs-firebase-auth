import 'package:auth_test/core/get_storage.dart';
import 'package:auth_test/feature/auth/bloc/auth_cubit.dart';
import 'package:auth_test/feature/auth/bloc/auth_state.dart';
import 'package:auth_test/feature/auth/email_validation_screen.dart';
import 'package:auth_test/feature/auth/widget/social_auth_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardScreen extends StatelessWidget {
  const OnboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: BlocConsumer<AuthCubit, AuthState>(
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  // Title
                  const Text(
                    'Welcome to\nHelper!',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Description
                  const Text(
                    'Here we will connect you with experts or specialists in various fields, so you can get consultation via text messages or videocall. Or be specialist to help people and earn money.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  // Create Account Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Create an Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Sign Up With
                  const Text(
                    'or Sign Up with',
                    style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                  ),
                  const SizedBox(height: 16),
                  // Social Buttons
                  SocialAuthSection(),
                  const SizedBox(height: 24),
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'I already have an account ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/login'),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
        listener: (BuildContext context, AuthState state) {
          if (state.status == AuthStatus.authenticated) {
            final isVerified = AuthStorage.getIsVerified() ?? false;

            if (isVerified) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            } else {
              EmailValidationScreen.open(context, '');
            }
          }
        },
      ),
    );
  }
}
