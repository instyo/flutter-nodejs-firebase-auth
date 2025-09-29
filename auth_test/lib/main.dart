import 'package:auth_test/feature/auth/bloc/auth_cubit.dart';
import 'package:auth_test/feature/auth/email_validation_screen.dart';
import 'package:auth_test/feature/auth/login_screen.dart';
import 'package:auth_test/feature/auth/onboard_screen.dart';
import 'package:auth_test/feature/auth/register_screen.dart';
import 'package:auth_test/feature/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialize firebase
  await Firebase.initializeApp();
  await GetStorage.init();
  runApp(const HelperApp());
}

class HelperApp extends StatelessWidget {
  const HelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: MaterialApp(
        title: 'Helper App',
        theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Inter'),
        home: const OnboardScreen(),
        routes: {
          '/onboard': (context) => const OnboardScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/validate-email': (context) => const EmailValidationScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
