// lib/presentation/blocs/auth/auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class SignIn extends AuthEvent {
  final String email;
  final String password;

  const SignIn({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class SignUp extends AuthEvent {
  final String email;
  final String password;
  final String confirmPassword;
  final String? name;

  const SignUp({
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.name,
  });

  @override
  List<Object?> get props => [email, password, confirmPassword, name];
}

class SignOut extends AuthEvent {}

class ResetPassword extends AuthEvent {
  final String email;

  const ResetPassword({required this.email});

  @override
  List<Object> get props => [email];
}