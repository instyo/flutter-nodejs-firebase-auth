import 'package:auth_test/core/get_storage.dart';
import 'package:auth_test/feature/auth/bloc/auth_cubit.dart';
import 'package:auth_test/feature/auth/bloc/auth_state.dart';
import 'package:auth_test/feature/auth/email_validation_screen.dart';
import 'package:auth_test/feature/auth/widget/custom_textfield.dart';
import 'package:auth_test/feature/auth/widget/social_auth_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: BlocConsumer<AuthCubit, AuthState>(
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const SizedBox(height: 60),
                    // Title
                    const Text(
                      'Create an Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Description
                    const Text(
                      "Create an account so you can use Helpers!",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Email Field
                    CustomTextfield(
                      label: 'Type your email',
                      hintText: 'yondu.dudu@helpert.com',
                      icon: Icons.email_outlined,
                      controller: emailController,
                    ),
                    const SizedBox(height: 16),
                    // Password Field
                    CustomTextfield(
                      label: 'Type your password',
                      hintText: '******',
                      icon: Icons.lock_outline,
                      controller: passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    // Confirm Password Field
                    CustomTextfield(
                      label: 'Confirm your password',
                      hintText: '******',
                      icon: Icons.lock_outline,
                      controller: confirmPasswordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    // Next Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (passwordController.text !=
                              confirmPasswordController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Passwords do not match"),
                              ),
                            );
                            return;
                          }

                          cubit.auth(
                            email: emailController.text,
                            password: passwordController.text,
                            type: AuthType.register,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: state.status == AuthStatus.loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Next',
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
                    const Center(
                      child: Text(
                        'or Sign Up with',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Social Buttons
                    SocialAuthSection(),
                    const SizedBox(height: 24),
                    // Sign In Link
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
                            'Sign In',
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
              return;
            } else {
              EmailValidationScreen.open(context, emailController.text);
            }
          }
        },
      ),
    );
  }
}
