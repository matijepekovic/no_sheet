// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'di/dependency_injection.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/customer/customer_bloc.dart';
import 'presentation/blocs/product/product_bloc.dart';
import 'presentation/blocs/project/project_bloc.dart';
import 'presentation/blocs/quote/quote_bloc.dart';

void main() async {
  // Ensure that the Flutter binding is initialized before initializing Firebase.
  // This is required for Firebase to function correctly within the Flutter application lifecycle.
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase for the current platform.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Print a success message if Firebase initializes correctly.
    print('Firebase initialized successfully');

    // Setup dependency injection
    setupDependencies();

  } catch (e) {
    // Print an error message if Firebase initialization fails.
    print('Failed to initialize Firebase: $e');
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>(),
        ),
        BlocProvider<CustomerBloc>(
          create: (context) => getIt<CustomerBloc>(),
        ),
        BlocProvider<ProductBloc>(
          create: (context) => getIt<ProductBloc>(),
        ),
        BlocProvider<ProjectBloc>(
          create: (context) => getIt<ProjectBloc>(),
        ),
        BlocProvider<QuoteBloc>(
          create: (context) => getIt<QuoteBloc>(),
        ),
      ],
      child: const NoSheetApp(),
    ),
  );
}