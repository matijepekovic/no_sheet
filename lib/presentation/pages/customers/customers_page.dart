// lib/presentation/pages/customers/customers_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Sorting options bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Text('Sort by: '),
                DropdownButton<String>(
                  value: _sortBy,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _sortBy = newValue;
                      });
                    }
                  },
                  items: <String>['name', 'date', 'email', 'phone']
                      .map<DropdownMenuItem<String>>((String value) {
                    String displayValue = value;
                    switch (value) {
                      case 'name':
                        displayValue = 'Name';
                        break;
                      case 'date':
                        displayValue = 'Date Added';
                        break;
                      case 'email':
                        displayValue = 'Email';
                        break;
                      case 'phone':
                        displayValue = 'Phone';
                        break;
                    }
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(displayValue),
                    );
                  }).toList(),
                ),
                IconButton(
                  icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: () {
                    setState(() {
                      _sortAscending = !_sortAscending;
                    });
                  },
                ),
                const Spacer(),
                // Filter indicator
                if (_showOnlyRecentCustomers)
                  Chip(
                    label: const Text('Recent Only'),
                    onDeleted: () {
                      setState(() {
                        _showOnlyRecentCustomers = false;
                      });
                    },
                  ),
              ],
            ),
          ),

          // Customers list
          Expanded(
            child: StreamBuilder<List<Customer>>(
              stream: _customerRepository.getCustomers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var customers = snapshot.data ?? [];

                // Apply search filtering if query exists
                if (_searchQuery != null && _searchQuery!.isNotEmpty) {
                  customers = customers.where((customer) =>
                  customer.name.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
                      customer.phone.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
                      (customer.email.isNotEmpty && customer.email.toLowerCase().contains(_searchQuery!.toLowerCase())))
                      .toList();
                }

                // Apply recent customers filter if enabled
                if (_showOnlyRecentCustomers) {
                  final threshold = DateTime.now().subtract(const Duration(days: 30));
                  customers = customers.where((customer) => customer.createdAt.isAfter(threshold)).toList();
                }

                // Apply sorting
                customers.sort((a, b) {
                  int compare;
                  switch (_sortBy) {
                    case 'name':
                      compare = a.name.compareTo(b.name);
                      break;
                    case 'date':
                      compare = a.createdAt.compareTo(b.createdAt);
                      break;
                    case 'email':
                      compare = a.email.compareTo(b.email);
                      break;
                    case 'phone':
                      compare = a.phone.compareTo(b.phone);
                      break;
                    default:
                      compare = a.name.compareTo(b.name);
                  }
                  return _sortAscending ? compare : -compare;
                });

                if (customers.isEmpty) {
                  return const Center(child: Text('No customers found'));
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
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            customer.name.isNotEmpty ? customer.name[0] : '?',
                            style: TextStyle(color: Colors.blue.shade800),
                          ),
                        ),
                        title: Text(customer.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(customer.phone),
                            Text(
                              'Added: ${DateFormat('MMM d, yyyy').format(customer.createdAt)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        isThreeLine: true,
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
          ),
        ],
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
        tooltip: 'Add New Customer',
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Customers'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              title: const Text('Show only recent customers (30 days)'),
              value: _showOnlyRecentCustomers,
              onChanged: (value) {
                setState(() {
                  _showOnlyRecentCustomers = value ?? false;
                });
                Navigator.pop(context);
              },
            ),
            // Add more filter options here as needed
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _showOnlyRecentCustomers = false;
                // Reset other filters here as needed
              });
              Navigator.pop(context);
            },
            child: const Text('RESET ALL'),
          ),
        ],
      ),
    );
  }
}