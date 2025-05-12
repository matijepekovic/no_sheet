// lib/presentation/pages/customers/customers_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/customer.dart';
import '../../../data/repositories/customer_repository_impl.dart';
import 'add_customer_page.dart';
import 'customer_detail_page.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({Key? key}) : super(key: key);

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  late final CustomerRepositoryImpl _customerRepository;

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
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
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

          if (customers.isEmpty) {
            return const Center(child: Text('No customers yet'));
          }

          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(customer.name[0]),
                  ),
                  title: Text(customer.name),
                  subtitle: Text(customer.phone),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
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
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
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