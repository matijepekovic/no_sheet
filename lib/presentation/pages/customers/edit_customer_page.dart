// lib/presentation/pages/customers/edit_customer_page.dart
import 'package:flutter/material.dart';
import '../../../data/models/customer.dart';
import '../../../data/repositories/customer_repository_impl.dart';

class EditCustomerPage extends StatefulWidget {
  final Customer customer;

  const EditCustomerPage({Key? key, required this.customer}) : super(key: key);

  @override
  State<EditCustomerPage> createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends State<EditCustomerPage> {
  // ... existing code ...

  void _updateCustomer() async {
    if (_formKey.currentState!.validate()) {
      // Prevent multiple submissions
      if (_isLoading) return;

      setState(() {
        _isLoading = true;
      });

      try {
        // Create updated customer object
        final updatedCustomer = widget.customer.copyWith(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          address: _addressController.text,
          notes: _notesController.text,
        );

        // Initialize repository
        const userId = 'test-user-id'; // Using a constant user ID for now
        final customerRepository = CustomerRepositoryImpl(
          userId: userId,
        );

        await customerRepository.updateCustomer(updatedCustomer);

        // Navigate FIRST, passing the updated customer
        if (!mounted) return;
        Navigator.pop(context, updatedCustomer);

        // Success message will be shown by the calling page
      } catch (e) {
        // Show error message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating customer: $e')),
        );

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

// ... rest of existing code ...
}