// lib/core/services/auth_service.dart
import 'dart:async';
import 'package:flutter/material.dart';

// Simple User class to replace Firebase User
class User {
  final String uid;
  final String email;
  final String? displayName;

  User({required this.uid, required this.email, this.displayName});
}

class AuthService {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Auth state stream controller
  final _authStateController = StreamController<User?>.broadcast();

  // Mock user data
  User? _currentUser;

  // Simulate checking if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  // Get current user ID with fallback for development
  String get currentUserId {
    return _currentUser?.uid ?? 'dev-user-id';
  }

  // Auth state changes stream
  Stream<User?> get authStateChanges => _authStateController.stream;

  // Sign in with email and password
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (email == 'test@example.com' && password == 'password') {
      _currentUser = User(
        uid: 'test-user-id',
        email: email,
        displayName: 'Test User',
      );
      _authStateController.add(_currentUser);
      return _currentUser!;
    } else {
      throw Exception('Invalid email or password');
    }
  }

  // Register with email and password
  Future<User> createUserWithEmailAndPassword(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = User(
      uid: 'new-user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: null,
    );
    _authStateController.add(_currentUser);
    return _currentUser!;
  }

  // Sign out
  Future<void> signOut() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    _currentUser = null;
    _authStateController.add(null);
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Just pretend it worked
    return;
  }

  // Get current user
  User? get currentUser => _currentUser;

  // Clean up when done
  void dispose() {
    _authStateController.close();
  }
}