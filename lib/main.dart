// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'di/dependency_injection.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/customer/customer_bloc.dart';
import 'presentation/blocs/product/product_bloc.dart';
import 'presentation/blocs/project/project_bloc.dart';
import 'presentation/blocs/quote/quote_bloc.dart';
import 'presentation/blocs/dashboard/dashboard_bloc.dart';

void main() {
  // Ensure that the Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependency injection
  setupDependencies();

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
        BlocProvider<DashboardBloc>(
          create: (context) => getIt<DashboardBloc>(),
        ),
      ],
      child: const NoSheetApp(),
    ),
  );
}