// lib/presentation/widgets/quote/quote_item_tile.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/quote_item.dart';

class QuoteItemTile extends StatelessWidget {
  final QuoteItem item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const QuoteItemTile({
    Key? key,
    required this.item,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                if (onEdit != null || onDelete != null)
                  Row(
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20.0),
                          onPressed: onEdit,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      if (onEdit != null && onDelete != null)
                        const SizedBox(width: 8.0),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20.0, color: Colors.red),
                          onPressed: onDelete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
              ],
            ),
            if (item.description.isNotEmpty) ...[
              const SizedBox(height: 4.0),
              Text(
                item.description,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item.quantity} ${item.unit ?? 'units'} × ${currencyFormat.format(item.unitPrice)}',
                ),
                Text(
                  currencyFormat.format(item.total),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}