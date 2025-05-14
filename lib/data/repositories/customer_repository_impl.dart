// lib/data/repositories/customer_repository_impl.dart
import 'package:flutter/material.dart';
import '../../domain/repositories/customer_repository.dart';
import '../models/customer.dart';
import '../../core/services/local_storage_service.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final LocalStorageService _storage = LocalStorageService();
  final String _userId;

  CustomerRepositoryImpl({
    required String userId,
  }) : _userId = userId;

  @override
  Stream<List<Customer>> getCustomers() {
    return _storage.getCustomers();
  }

  @override
  Future<Customer?> getCustomer(String id) async {
    return await _storage.getCustomer(id);
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    await _storage.addCustomer(customer);
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    await _storage.updateCustomer(customer);
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await _storage.deleteCustomer(id);
  }
}