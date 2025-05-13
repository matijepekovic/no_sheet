// lib/presentation/blocs/auth/auth_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import '../../../domain/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authStateSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignIn>(_onSignIn);
    on<SignUp>(_onSignUp);
    on<SignOut>(_onSignOut);
    on<ResetPassword>(_onResetPassword);

    // Listen to auth state changes
    _authStateSubscription = _authRepository.authStateChanges.listen(
          (user) {
        if (user != null) {
          add(CheckAuthStatus());
        } else {
          emit(Unauthenticated());
        }
      },
    );
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatus event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      final user = _authRepository.currentUser;
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignIn(
      SignIn event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.signInWithEmailAndPassword(
        event.email,
        event.password,
      );
      emit(Authenticated(result.user!));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getMessageFromErrorCode(e.code)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUp(
      SignUp event,
      Emitter<AuthState> emit,
      ) async {
    // Validate password match
    if (event.password != event.confirmPassword) {
      emit(const AuthError('Passwords do not match'));
      return;
    }

    emit(AuthLoading());
    try {
      final result = await _authRepository.createUserWithEmailAndPassword(
        event.email,
        event.password,
      );

      // Update display name if provided
      if (event.name != null && event.name!.isNotEmpty) {
        await result.user!.updateDisplayName(event.name);
      }

      emit(Authenticated(result.user!));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getMessageFromErrorCode(e.code)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(
      SignOut event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onResetPassword(
      ResetPassword event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      await _authRepository.resetPassword(event.email);
      emit(PasswordResetSent(event.email));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getMessageFromErrorCode(e.code)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  String _getMessageFromErrorCode(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'Email address is not valid';
      case 'user-disabled':
        return 'User has been disabled';
      case 'user-not-found':
        return 'User not found';
      case 'wrong-password':
        return 'Password is incorrect';
      case 'email-already-in-use':
        return 'Email is already in use by another account';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'weak-password':
        return 'Password is too weak';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}