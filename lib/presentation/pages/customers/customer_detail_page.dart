// lib/presentation/pages/customers/customer_detail_page.dart
import 'package:flutter/material.dart';
import '../../../data/models/customer.dart';
import 'edit_customer_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/repositories/customer_repository_impl.dart';

class CustomerDetailPage extends StatelessWidget {
  final Customer customer;

  const CustomerDetailPage({Key? key, required this.customer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updatedCustomer = await Navigator.push<Customer>(
                context,
                MaterialPageRoute(
                  builder: (context) => EditCustomerPage(customer: customer),
                ),
              );

              if (updatedCustomer != null) {
                // After getting updated customer, go back to customer list
                Navigator.pop(context, updatedCustomer);

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Customer updated successfully')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.person, 'Name', customer.name),
                    const Divider(),
                    _buildInfoRow(Icons.email, 'Email', customer.email),
                    const Divider(),
                    _buildInfoRow(Icons.phone, 'Phone', customer.phone),
                    const Divider(),
                    _buildInfoRow(Icons.location_on, 'Address', customer.address),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            _buildNotesSection(),
            const SizedBox(height: 16.0),
            _buildQuotesSection(context),
            const SizedBox(height: 16.0),
            _buildProjectsSection(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to create quote page with this customer
        },
        icon: const Icon(Icons.add),
        label: const Text('New Quote'),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              customer.notes ?? 'No notes available',
              style: TextStyle(
                fontSize: 16.0,
                fontStyle: customer.notes == null ? FontStyle.italic : null,
                color: customer.notes == null ? Colors.grey : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotesSection(BuildContext context) {
    // This would eventually fetch quotes for this customer
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quotes',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all quotes for this customer
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No quotes yet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsSection(BuildContext context) {
    // This would eventually fetch projects for this customer
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Projects',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all projects for this customer
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No projects yet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete ${customer.name}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Just close dialog
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              // Show loading indicator in dialog
              showDialog(
                context: dialogContext,
                barrierDismissible: false,
                builder: (_) => const AlertDialog(
                  content: SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              );

              try {
                // Initialize repository
                final userId = FirebaseAuth.instance.currentUser?.uid ?? 'test-user-id';
                final customerRepository = CustomerRepositoryImpl(
                  firestore: FirebaseFirestore.instance,
                  userId: userId,
                );

                // Delete from Firestore
                await customerRepository.deleteCustomer(customer.id);

                // Explicitly close all dialogs and navigate back
                Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/customers');

                // Use a delay to ensure navigation completes before showing snackbar
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Customer deleted successfully')),
                    );
                  }
                });
              } catch (e) {
                // Close any open dialogs
                Navigator.of(context).pop();
                Navigator.of(dialogContext).pop();

                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting customer: $e')),
                );
              }
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }}