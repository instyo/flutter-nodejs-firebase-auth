import 'package:equatable/equatable.dart';

enum AuthStatus { idle, authenticated, unauthenticated, loading, unknown, error }

class AuthState extends Equatable {
  final AuthStatus status;
  const AuthState({this.status = AuthStatus.idle});

  AuthState copyWith({AuthStatus? status}) {
    return AuthState(status: status ?? this.status);
  }

  @override
  List<Object?> get props => [status];
}
