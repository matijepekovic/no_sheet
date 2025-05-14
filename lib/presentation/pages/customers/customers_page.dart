// lib/presentation/pages/customers/customers_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/customer.dart';
import '../../../data/repositories/customer_repository_impl.dart';
import 'add_customer_page.dart';
import 'customer_detail_page.dart';

class CustomersPage extends StatefulWidget {
  final bool selectionMode;

  const CustomersPage({Key? key, this.selectionMode = false}) : super(key: key);

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  late final CustomerRepositoryImpl _customerRepository;
  String? _searchQuery;
  String _sortBy = 'name'; // Default sort by name
  bool _sortAscending = true; // Default ascending order

  // Filter options
  bool _showOnlyRecentCustomers = false;

  @override
  void initState() {
    super.initState();
    // Initialize repository with test user ID
    const userId = 'test-user-id';
    _customerRepository = CustomerRepositoryImpl(
      userId: userId,
    );
  }

// ... rest of existing code ...
}