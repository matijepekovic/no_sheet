// lib/data/repositories/customer_repository_impl.dart - use this fixed version
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/repositories/customer_repository.dart';
import '../models/customer.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  CustomerRepositoryImpl({
    required FirebaseFirestore firestore,
    required String userId,
  }) : _firestore = firestore, _userId = userId;

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _customersCollection =>
      _firestore.collection('customers');

  @override
  Stream<List<Customer>> getCustomers() {
    try {
      print('Getting customers for business ID: $_userId');

      return _customersCollection
          .where('businessId', isEqualTo: _userId)
          .orderBy('name')
          .snapshots()
          .handleError((error) {
        // Log the error for debugging
        print('Error getting customers: $error');

        // If the error is about missing indexes, show a more helpful message
        if (error.toString().contains('The query requires an index')) {
          print('Firestore index is being built. This may take a few minutes.');
        }

        // Return an empty list instead of throwing
        return [];
      })
          .map((snapshot) => snapshot.docs
          .map((doc) => Customer.fromFirestore(doc))
          .toList());
    } catch (e) {
      print('Error setting up customer stream: $e');
      return Stream.value([]);
    }
  }

  @override
  Future<Customer> getCustomer(String id) async {
    try {
      final doc = await _customersCollection.doc(id).get();
      if (!doc.exists) {
        throw Exception('Customer not found');
      }
      return Customer.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error getting customer: $e');
      rethrow;
    }
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    try {
      await _customersCollection.doc(customer.id).set(customer.toMap());
    } catch (e) {
      debugPrint('Error adding customer: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    try {
      await _customersCollection.doc(customer.id).update(customer.toMap());
    } catch (e) {
      debugPrint('Error updating customer: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try {
      await _customersCollection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting customer: $e');
      rethrow;
    }
  }
}