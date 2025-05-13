// lib/presentation/blocs/dashboard/dashboard_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../../../domain/repositories/customer_repository.dart';
import '../../../domain/repositories/quote_repository.dart';
import '../../../domain/repositories/project_repository.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/quote.dart';
import '../../../data/models/project.dart';
import '../../../data/models/product.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final CustomerRepository _customerRepository;
  final QuoteRepository _quoteRepository;
  final ProjectRepository _projectRepository;
  final ProductRepository _productRepository;

  StreamSubscription? _customersSubscription;
  StreamSubscription? _quotesSubscription;
  StreamSubscription? _projectsSubscription;
  StreamSubscription? _productsSubscription;

  List<Customer> _customers = [];
  List<Quote> _quotes = [];
  List<Project> _projects = [];
  List<Product> _products = [];

  DashboardBloc({
    required CustomerRepository customerRepository,
    required QuoteRepository quoteRepository,
    required ProjectRepository projectRepository,
    required ProductRepository productRepository,
  }) : _customerRepository = customerRepository,
        _quoteRepository = quoteRepository,
        _projectRepository = projectRepository,
        _productRepository = productRepository,
        super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
  }

  Future<void> _onLoadDashboardData(
      LoadDashboardData event,
      Emitter<DashboardState> emit,
      ) async {
    emit(DashboardLoading());
    try {
      // Listen to all repositories
      await _setupSubscriptions();
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onRefreshDashboardData(
      RefreshDashboardData event,
      Emitter<DashboardState> emit,
      ) async {
    // Cancel existing subscriptions
    await _cancelSubscriptions();

    // Reload data
    add(LoadDashboardData());
  }

  Future<void> _setupSubscriptions() async {
    await _cancelSubscriptions();

    _customersSubscription = _customerRepository.getCustomers().listen(
          (customers) {
        _customers = customers;
        _updateDashboardState();
      },
      onError: (error) => add(DashboardError(error.toString()) as DashboardEvent),
    );

    _quotesSubscription = _quoteRepository.getQuotes().listen(
          (quotes) {
        _quotes = quotes;
        _updateDashboardState();
      },
      onError: (error) => add(DashboardError(error.toString()) as DashboardEvent),
    );

    _projectsSubscription = _projectRepository.getProjects().listen(
          (projects) {
        _projects = projects;
        _updateDashboardState();
      },
      onError: (error) => add(DashboardError(error.toString()) as DashboardEvent),
    );

    _productsSubscription = _productRepository.getProducts().listen(
          (products) {
        _products = products;
        _updateDashboardState();
      },
      onError: (error) => add(DashboardError(error.toString()) as DashboardEvent),
    );
  }

  void _updateDashboardState() {
    // Create recent activities list (most recent items from all repositories)
    final recentActivities = _generateRecentActivities();

    emit(DashboardLoaded(
      customerCount: _customers.length,
      quoteCount: _quotes.length,
      projectCount: _projects.length,
      productCount: _products.length,
      recentActivities: recentActivities,
    ));
  }

  List<dynamic> _generateRecentActivities() {
    final List<dynamic> activities = [];

    // Add recent quotes
    activities.addAll(_quotes.take(3).map((quote) => {
      'type': 'quote',
      'title': 'New Quote Created',
      'description': quote.title,
      'time': quote.createdAt,
      'id': quote.id,
    }));

    // Add recent customers
    activities.addAll(_customers.take(3).map((customer) => {
      'type': 'customer',
      'title': 'New Customer Added',
      'description': customer.name,
      'time': customer.createdAt,
      'id': customer.id,
    }));

    // Add recent projects
    activities.addAll(_projects.take(3).map((project) => {
      'type': 'project',
      'title': 'New Project Created',
      'description': project.title,
      'time': project.startDate,
      'id': project.id,
    }));

    // Sort all activities by time (most recent first)
    activities.sort((a, b) => b['time'].compareTo(a['time']));

    // Return the 5 most recent activities
    return activities.take(5).toList();
  }

  Future<void> _cancelSubscriptions() async {
    await _customersSubscription?.cancel();
    await _quotesSubscription?.cancel();
    await _projectsSubscription?.cancel();
    await _productsSubscription?.cancel();
  }

  @override
  Future<void> close() {
    _cancelSubscriptions();
    return super.close();
  }
}