// lib/di/dependency_injection.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import '../presentation/blocs/dashboard/dashboard_bloc.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/customer_repository_impl.dart';
import '../data/repositories/product_repository_impl.dart';
import '../data/repositories/project_repository_impl.dart';
import '../data/repositories/quote_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/customer_repository.dart';
import '../domain/repositories/product_repository.dart';
import '../domain/repositories/project_repository.dart';
import '../domain/repositories/quote_repository.dart';
import '../core/services/pdf_service.dart';
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/customer/customer_bloc.dart';
import '../presentation/blocs/product/product_bloc.dart';
import '../presentation/blocs/project/project_bloc.dart';
import '../presentation/blocs/quote/quote_bloc.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Firebase services
  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton(() => FirebaseStorage.instance);

  // Core services
  getIt.registerLazySingleton(() => PdfService());

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(auth: getIt<FirebaseAuth>()),
  );

  getIt.registerFactory<CustomerRepository>(
        () => CustomerRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      userId: getIt<FirebaseAuth>().currentUser?.uid ?? 'test-user-id',
    ),
  );

  getIt.registerFactory<ProductRepository>(
        () => ProductRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      userId: getIt<FirebaseAuth>().currentUser?.uid ?? 'test-user-id',
    ),
  );

  getIt.registerFactory<ProjectRepository>(
        () => ProjectRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      userId: getIt<FirebaseAuth>().currentUser?.uid ?? 'test-user-id',
    ),
  );

  getIt.registerFactory<QuoteRepository>(
        () => QuoteRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      storage: getIt<FirebaseStorage>(),
      userId: getIt<FirebaseAuth>().currentUser?.uid ?? 'test-user-id',
      pdfService: getIt<PdfService>(),
    ),
  );

  // BLoCs
  getIt.registerFactory(
        () => AuthBloc(authRepository: getIt<AuthRepository>()),
  );

  getIt.registerFactory(
        () => CustomerBloc(customerRepository: getIt<CustomerRepository>()),
  );

  getIt.registerFactory(
        () => ProductBloc(productRepository: getIt<ProductRepository>()),
  );

  getIt.registerFactory(
        () => ProjectBloc(projectRepository: getIt<ProjectRepository>()),
  );

  getIt.registerFactory(
        () => QuoteBloc(quoteRepository: getIt<QuoteRepository>()),
  );
  getIt.registerFactory(
        () => DashboardBloc(
      customerRepository: getIt<CustomerRepository>(),
      quoteRepository: getIt<QuoteRepository>(),
      projectRepository: getIt<ProjectRepository>(),
      productRepository: getIt<ProductRepository>(),
    ),
  );
}