// lib/data/repositories/customer_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
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
    return _customersCollection
        .where('businessId', isEqualTo: _userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Customer.fromFirestore(doc))
        .toList());
  }

  @override
  Future<Customer> getCustomer(String id) async {
    final doc = await _customersCollection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Customer not found');
    }
    return Customer.fromFirestore(doc);
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    await _customersCollection.doc(customer.id).set(customer.toMap());
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    await _customersCollection.doc(customer.id).update(customer.toMap());
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await _customersCollection.doc(id).delete();
  }
}