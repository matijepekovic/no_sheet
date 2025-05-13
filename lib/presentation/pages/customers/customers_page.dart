// lib/presentation/pages/customers/customers_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();
    // Initialize repository - use a dummy user ID until auth is implemented
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'test-user-id';
    _customerRepository = CustomerRepositoryImpl(
      firestore: FirebaseFirestore.instance,
      userId: userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _searchQuery == null
            ? const Text('Customers')
            : TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search customers...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          if (_searchQuery == null)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _searchQuery = null;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Implement filter functionality
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Customer>>(
        stream: _customerRepository.getCustomers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final customers = snapshot.data ?? [];

          // Apply search filtering if query exists
          final filteredCustomers = _searchQuery != null && _searchQuery!.isNotEmpty
              ? customers.where((customer) =>
          customer.name.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
              customer.phone.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
              (customer.email.isNotEmpty && customer.email.toLowerCase().contains(_searchQuery!.toLowerCase())))
              .toList()
              : customers;

          if (filteredCustomers.isEmpty) {
            return const Center(child: Text('No customers found'));
          }

          return ListView.builder(
            itemCount: filteredCustomers.length,
            itemBuilder: (context, index) {
              final customer = filteredCustomers[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      customer.name[0],
                      style: TextStyle(color: Colors.blue.shade800),
                    ),
                  ),
                  title: Text(customer.name),
                  subtitle: Text(customer.phone),
                  trailing: widget.selectionMode
                      ? const Icon(Icons.check_circle_outline)
                      : const Icon(Icons.chevron_right),
                  onTap: () async {
                    if (widget.selectionMode) {
                      // Return selected customer to previous page
                      Navigator.pop(context, customer);
                    } else {
                      final result = await Navigator.push<Customer?>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerDetailPage(customer: customer),
                        ),
                      );

                      if (result != null) {
                        // Customer was updated
                        await _customerRepository.updateCustomer(result);
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: widget.selectionMode
          ? FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCustomerPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add New Customer',
      )
          : FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCustomerPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}