// lib/data/models/customer.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? notes;
  final DateTime createdAt;
  final String? businessId;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.notes,
    required this.createdAt,
    this.businessId,
  });

  // Create from Firestore document
  factory Customer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Customer(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      businessId: data['businessId'],
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'businessId': businessId,
    };
  }

  // Copy with new values
  Customer copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? notes,
    String? businessId,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      businessId: businessId ?? this.businessId,
    );
  }
}