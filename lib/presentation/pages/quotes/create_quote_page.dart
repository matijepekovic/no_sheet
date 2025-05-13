// lib/presentation/pages/quotes/create_quote_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/quote.dart';
import '../../../data/models/quote_item.dart';
import '../../../data/models/customer.dart';
import '../../blocs/quote/quote_bloc.dart';
import '../../blocs/quote/quote_event.dart';
import '../../blocs/quote/quote_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_dialog.dart';
import '../../widgets/quote/quote_item_tile.dart';
import '../customers/customers_page.dart';

class CreateQuotePage extends StatefulWidget {
  final Customer? selectedCustomer;

  const CreateQuotePage({Key? key, this.selectedCustomer}) : super(key: key);

  @override
  State<CreateQuotePage> createState() => _CreateQuotePageState();
}

class _CreateQuotePageState extends State<CreateQuotePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _validUntilController;
  late TextEditingController _taxRateController;
  late TextEditingController _discountController;
  late TextEditingController _notesController;

  Customer? _selectedCustomer;
  DateTime _validUntil = DateTime.now().add(const Duration(days: 30));
  double _taxRate = 0.0;
  double _discount = 0.0;
  final List<QuoteItem> _items = [];

  double _subtotal = 0.0;
  double _taxAmount = 0.0;
  double _total = 0.0;

  final _dateFormat = DateFormat('MM/dd/yyyy');
  final _currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    _selectedCustomer = widget.selectedCustomer;

    _titleController = TextEditingController(text: 'Quote for ${_selectedCustomer?.name ?? ""}');
    _validUntilController = TextEditingController(text: _dateFormat.format(_validUntil));
    _taxRateController = TextEditingController(text: _taxRate.toString());
    _discountController = TextEditingController(text: _discount.toString());
    _notesController = TextEditingController();

    _updateTotals();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _validUntilController.dispose();
    _taxRateController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateTotals() {
    setState(() {
      _subtotal = _items.fold(0.0, (sum, item) => sum + item.total);
      _taxAmount = _subtotal * (_taxRate / 100);
      _total = _subtotal + _taxAmount - _discount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quote'),
        actions: [
          BlocConsumer<QuoteBloc, QuoteState>(
            listener: (context, state) {
              if (state is QuoteOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
                Navigator.pop(context);
              } else if (state is QuoteOperationFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is QuoteOperationLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                );
              }

              return IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveQuote,
              );
            },
          ),
        ],
      ),
      body: BlocListener<QuoteBloc, QuoteState>(
        listener: (context, state) {
          if (state is QuoteError) {
            showDialog(
              context: context,
              builder: (context) => ErrorDialog(message: state.message),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Customer selection
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(_selectedCustomer?.name ?? 'Select Customer'),
                  subtitle: _selectedCustomer != null
                      ? Text(_selectedCustomer!.phone)
                      : const Text('Tap to select a customer'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
                  onTap: _selectCustomer,
                ),
              ),

              const SizedBox(height: 16.0),

              // Quote details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quote Details',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Title field
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Quote Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16.0),

                      // Valid until date
                      TextFormField(
                        controller: _validUntilController,
                        decoration: const InputDecoration(
                          labelText: 'Valid Until',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _validUntil,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );

                          if (pickedDate != null) {
                            setState(() {
                              _validUntil = pickedDate;
                              _validUntilController.text = _dateFormat.format(pickedDate);
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16.0),

                      // Tax rate and discount in a row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _taxRateController,
                              decoration: const InputDecoration(
                                labelText: 'Tax Rate (%)',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.percent),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  _taxRate = double.tryParse(value) ?? 0.0;
                                  _updateTotals();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: TextFormField(
                              controller: _discountController,
                              decoration: const InputDecoration(
                                labelText: 'Discount Amount',
                                border: OutlineInputBorder(),
                                prefixText: '\$',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  _discount = double.tryParse(value) ?? 0.0;
                                  _updateTotals();
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16.0),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16.0),

              // Quote items
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Items',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _addItem,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Item'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8.0),

                      // List of items
                      _items.isEmpty
                          ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text('No items added yet'),
                        ),
                      )
                          : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];

                          return QuoteItemTile(
                            item: item,
                            onEdit: () => _editItem(index),
                            onDelete: () => _deleteItem(index),
                          );
                        },
                      ),

                      // Totals section
                      const Divider(),

                      // Display totals
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal:'),
                          Text(_currencyFormat.format(_subtotal)),
                        ],
                      ),
                      const SizedBox(height: 4.0),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tax (${_taxRate.toStringAsFixed(2)}%):'),
                          Text(_currencyFormat.format(_taxAmount)),
                        ],
                      ),
                      const SizedBox(height: 4.0),

                      if (_discount > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Discount:'),
                            Text('-${_currencyFormat.format(_discount)}'),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                      ],

                      const Divider(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          Text(
                            _currencyFormat.format(_total),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectCustomer() async {
    final selectedCustomer = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomersPage(selectionMode: true),
      ),
    );

    if (selectedCustomer != null) {
      setState(() {
        _selectedCustomer = selectedCustomer;
        if (_titleController.text.isEmpty || _titleController.text == 'Quote for ${widget.selectedCustomer?.name ?? ""}') {
          _titleController.text = 'Quote for ${selectedCustomer.name}';
        }
      });
    }
  }

  void _addItem() {
    _showItemDialog();
  }

  void _editItem(int index) {
    _showItemDialog(existingItem: _items[index], index: index);
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
      _updateTotals();
    });
  }

  void _showItemDialog({QuoteItem? existingItem, int? index}) {
    final isEditing = existingItem != null;

    final nameController = TextEditingController(text: existingItem?.name);
    final descriptionController = TextEditingController(text: existingItem?.description);
    final unitPriceController = TextEditingController(text: existingItem?.unitPrice.toString() ?? '0.0');
    final quantityController = TextEditingController(text: existingItem?.quantity.toString() ?? '1.0');
    final unitController = TextEditingController(text: existingItem?.unit);

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Item' : 'Add Item'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name*',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16.0),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: unitPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Unit Price*',
                          border: OutlineInputBorder(),
                          prefixText: '\$',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: TextFormField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity*',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                TextFormField(
                  controller: unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unit (e.g., hours, pieces)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final name = nameController.text;
                final description = descriptionController.text;
                final unitPrice = double.parse(unitPriceController.text);
                final quantity = double.parse(quantityController.text);
                final unit = unitController.text.isEmpty ? null : unitController.text;

                final item = QuoteItem.create(
                  id: existingItem?.id ?? const Uuid().v4(),
                  name: name,
                  description: description,
                  unitPrice: unitPrice,
                  quantity: quantity,
                  unit: unit,
                );

                if (isEditing && index != null) {
                  setState(() {
                    _items[index] = item;
                    _updateTotals();
                  });
                } else {
                  setState(() {
                    _items.add(item);
                    _updateTotals();
                  });
                }

                Navigator.of(context).pop();
              }
            },
            child: Text(isEditing ? 'UPDATE' : 'ADD'),
          ),
        ],
      ),
    );
  }

  void _saveQuote() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCustomer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a customer')),
        );
        return;
      }

      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one item')),
        );
        return;
      }

      // Create a new quote
      final quote = Quote(
        id: const Uuid().v4(),
        customerId: _selectedCustomer!.id,
        customerName: _selectedCustomer!.name,
        title: _titleController.text,
        createdAt: DateTime.now(),
        validUntil: _validUntil,
        businessId: _selectedCustomer!.businessId ?? '',  // Should come from business context
        subtotal: _subtotal,
        taxRate: _taxRate,
        taxAmount: _taxAmount,
        discount: _discount,
        total: _total,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        status: QuoteStatus.draft,
        items: _items,
      );

      // Save the quote
      context.read<QuoteBloc>().add(AddQuote(quote));
    }
  }
}