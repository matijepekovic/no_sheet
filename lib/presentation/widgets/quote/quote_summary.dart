// lib/presentation/widgets/quote/quote_summary.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/quote.dart';

class QuoteSummary extends StatelessWidget {
  final Quote quote;
  final bool showActions;
  final VoidCallback? onViewDetails;
  final VoidCallback? onSend;

  const QuoteSummary({
    Key? key,
    required this.quote,
    this.showActions = true,
    this.onViewDetails,
    this.onSend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MM/dd/yyyy');

    // Choose a color based on quote status
    Color statusColor;
    switch (quote.status) {
      case QuoteStatus.draft:
        statusColor = Colors.grey;
        break;
      case QuoteStatus.sent:
        statusColor = Colors.blue;
        break;
      case QuoteStatus.accepted:
        statusColor = Colors.green;
        break;
      case QuoteStatus.rejected:
        statusColor = Colors.red;
        break;
      case QuoteStatus.expired:
        statusColor = Colors.orange;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    quote.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    quote.status.name.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16.0, color: Colors.grey),
                const SizedBox(width: 4.0),
                Text(
                  quote.customerName ?? 'Customer ID: ${quote.customerId}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16.0, color: Colors.grey),
                    const SizedBox(width: 4.0),
                    Text(
                      dateFormat.format(quote.createdAt),
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
                Text(
                  '${quote.items.length} items | ${currencyFormat.format(quote.total)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (showActions && (onViewDetails != null || onSend != null)) ...[
              const SizedBox(height: 8.0),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onViewDetails != null)
                    TextButton.icon(
                      onPressed: onViewDetails,
                      icon: const Icon(Icons.visibility),
                      label: const Text('View'),
                    ),
                  if (onSend != null && quote.status == QuoteStatus.draft) ...[
                    const SizedBox(width: 8.0),
                    TextButton.icon(
                      onPressed: onSend,
                      icon: const Icon(Icons.send),
                      label: const Text('Send'),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}