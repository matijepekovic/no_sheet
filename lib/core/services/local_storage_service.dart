// lib/core/services/local_storage_service.dart
import 'dart:async';
import '../../data/models/customer.dart';
import '../../data/models/product.dart';
import '../../data/models/project.dart';
import '../../data/models/quote.dart';

class LocalStorageService {
  // Singleton instance
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  // In-memory storage
  final Map<String, Customer> _customers = {};
  final Map<String, Product> _products = {};
  final Map<String, Project> _projects = {};
  final Map<String, Quote> _quotes = {};

  // Stream controllers to mimic Firebase streams
  final _customersStreamController = StreamController<List<Customer>>.broadcast();
  final _productsStreamController = StreamController<List<Product>>.broadcast();
  final _projectsStreamController = StreamController<List<Project>>.broadcast();
  final _quotesStreamController = StreamController<List<Quote>>.broadcast();

  // Customer methods
  Future<void> addCustomer(Customer customer) async {
    _customers[customer.id] = customer;
    _notifyCustomersListeners();
  }

  Future<void> updateCustomer(Customer customer) async {
    _customers[customer.id] = customer;
    _notifyCustomersListeners();
  }

  Future<void> deleteCustomer(String id) async {
    _customers.remove(id);
    _notifyCustomersListeners();
  }

  Future<Customer?> getCustomer(String id) async {
    return _customers[id];
  }

  Stream<List<Customer>> getCustomers() {
    _notifyCustomersListeners();
    return _customersStreamController.stream;
  }

  void _notifyCustomersListeners() {
    if (!_customersStreamController.isClosed) {
      _customersStreamController.add(_customers.values.toList());
    }
  }

  // Similar methods for products, projects, and quotes
  // ...

  // Clean up controllers when the app is done
  void dispose() {
    _customersStreamController.close();
    _productsStreamController.close();
    _projectsStreamController.close();
    _quotesStreamController.close();
  }
}