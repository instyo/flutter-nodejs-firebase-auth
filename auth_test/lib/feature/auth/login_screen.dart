import 'package:auth_test/feature/auth/bloc/auth_cubit.dart';
import 'package:auth_test/feature/auth/bloc/auth_state.dart';
import 'package:auth_test/feature/auth/widget/custom_textfield.dart';
import 'package:auth_test/feature/auth/widget/social_auth_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: BlocConsumer<AuthCubit, AuthState>(
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  // Title
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  const Text(
                    "We're happy to see. You can Login and continue consulting your problem or read some tips.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Username Field
                  CustomTextfield(
                    label: 'Type your email',
                    hintText: 'test@gmail.com',
                    icon: Icons.person_outline,
                    controller: emailController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextfield(
                    label: 'Type your password',
                    hintText: '********',
                    icon: Icons.lock_outline,
                    controller: passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        // cubit.log
                      },
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        cubit.auth(
                          email: emailController.text,
                          password: passwordController.text,
                          type: AuthType.login,
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Sign In With
                  const Center(
                    child: Text(
                      'or Sign In with',
                      style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Social Buttons
                  SocialAuthSection(),
                  const SizedBox(height: 24),
                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "I don't have an account ",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/register'),
                        child: const Text(
                          'Sign Up',
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
        listener: (BuildContext context, AuthState state) {},
      ),
    );
  }
}
