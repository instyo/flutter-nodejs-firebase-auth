import 'package:auth_test/core/auth_model.dart';
import 'package:auth_test/core/firebase_service.dart';
import 'package:auth_test/core/get_storage.dart';
import 'package:auth_test/feature/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AuthType { login, register }

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());

  final firebaseService = FirebaseService();

  Future<void> auth({
    required String email,
    required String password,
    required AuthType type,
  }) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final result = type == AuthType.login
          ? await firebaseService.loginWithEmail(email, password)
          : await firebaseService.registerWithEmail(email, password);

      if (result == null) {
        emit(state.copyWith(status: AuthStatus.error));
        return;
      }

      debugPrint('Auth Result: $result');

      final user = AuthModel.fromJson(result['user']);
      AuthStorage.saveAuthData(user.toJson());

      // Optionally, make an authenticated request to your backend
      emit(state.copyWith(status: AuthStatus.authenticated));
    } catch (e, s) {
      debugPrint('Auth Error: $e, $s');
      emit(state.copyWith(status: AuthStatus.error));
    }
  }

  Future<void> googleAuth() async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final result = await firebaseService.signInWithGoogle();

      debugPrint('Auth Result: $result');

      final user = AuthModel.fromJson(result?['user']);
      AuthStorage.saveAuthData(user.toJson());

      emit(state.copyWith(status: AuthStatus.authenticated));
    } catch (e, s) {
      debugPrint('Auth Error: $e, $s');
      emit(state.copyWith(status: AuthStatus.error));
    }
  }

  Future<void> appleAuth() async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final result = await firebaseService.signInWithApple();

      if (result == null) {
        emit(state.copyWith(status: AuthStatus.error));
        return;
      }

      debugPrint('Apple Auth Result: $result');

      final user = AuthModel.fromJson(result['user']);
      AuthStorage.saveAuthData(user.toJson());

      emit(state.copyWith(status: AuthStatus.authenticated));
    } catch (e, s) {
      debugPrint('Apple Auth Error: $e, $s');
      emit(state.copyWith(status: AuthStatus.error));
    }
  }
}
