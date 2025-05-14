// lib/presentation/pages/customers/add_customer_page.dart
import 'package:flutter/material.dart';
import '../../../data/models/customer.dart';
import '../../../data/repositories/customer_repository_impl.dart';

class AddCustomerPage extends StatefulWidget {
  const AddCustomerPage({Key? key}) : super(key: key);

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  // ... existing code ...

  void _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
      // Prevent multiple submissions
      if (_isLoading) return;

      // Show loading indicator
      setState(() {
        _isLoading = true;
      });

      try {
        // Create customer object
        const userId = 'test-user-id'; // Using a constant user ID for now
        final newCustomer = Customer(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          address: _addressController.text,
          notes: _notesController.text,
          createdAt: DateTime.now(),
          businessId: userId,
        );

        // Initialize repository
        final customerRepository = CustomerRepositoryImpl(
          userId: userId,
        );

        // Save customer
        await customerRepository.addCustomer(newCustomer);

        // Navigate FIRST
        if (!mounted) return;
        Navigator.pop(context);

        // Then show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer added successfully')),
        );
      } catch (e) {
        // Show error message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding customer: $e')),
        );

        // Reset loading state to allow retrying
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

// ... rest of existing code ...
}