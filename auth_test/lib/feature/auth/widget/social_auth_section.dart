import 'package:auth_test/core/get_storage.dart';
import 'package:auth_test/feature/auth/bloc/auth_cubit.dart';
import 'package:auth_test/feature/auth/bloc/auth_state.dart';
import 'package:auth_test/feature/auth/email_validation_screen.dart';
import 'package:auth_test/feature/auth/widget/social_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SocialAuthSection extends StatelessWidget {
  const SocialAuthSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    return BlocConsumer<AuthCubit, AuthState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SocialButton(
              imagePath: 'assets/images/apple.png',
              onPressed: () {
                cubit.appleAuth();
              },
            ),
            const SizedBox(width: 16),
            SocialButton(
              imagePath: 'assets/images/google.png',
              onPressed: () {
                cubit.googleAuth();
              },
            ),
          ],
        );
      },
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          final isVerified = AuthStorage.getIsVerified() ?? false;

          if (isVerified) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          } else {
            EmailValidationScreen.open(context, "");
          }
        }
      },
    );
  }
}
