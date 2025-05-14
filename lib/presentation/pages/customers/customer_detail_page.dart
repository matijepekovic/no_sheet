// lib/presentation/pages/customers/customer_detail_page.dart
import 'package:flutter/material.dart';
import '../../../data/models/customer.dart';
import 'edit_customer_page.dart';
import '../../../data/repositories/customer_repository_impl.dart';

class CustomerDetailPage extends StatelessWidget {
  final Customer customer;

  const CustomerDetailPage({Key? key, required this.customer}) : super(key: key);

  // ... existing code ...

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
                const userId = 'test-user-id'; // Using a constant user ID for now
                final customerRepository = CustomerRepositoryImpl(
                  userId: userId,
                );

                // Delete customer
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
  }
}