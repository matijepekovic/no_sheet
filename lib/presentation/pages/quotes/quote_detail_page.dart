// lib/presentation/pages/quotes/quote_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/quote.dart';
import '../../blocs/quote/quote_bloc.dart';
import '../../blocs/quote/quote_event.dart';
import '../../blocs/quote/quote_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_dialog.dart';
import '../../widgets/quote/quote_item_tile.dart';
import 'quote_preview_page.dart';

class QuoteDetailPage extends StatefulWidget {
  final String quoteId;

  const QuoteDetailPage({Key? key, required this.quoteId}) : super(key: key);

  @override
  State<QuoteDetailPage> createState() => _QuoteDetailPageState();
}

class _QuoteDetailPageState extends State<QuoteDetailPage> {
  final _currencyFormat = NumberFormat.currency(symbol: '\$');
  final _dateFormat = DateFormat('MM/dd/yyyy');

  @override
  void initState() {
    super.initState();
    // Load quote when page initializes
    context.read<QuoteBloc>().add(LoadQuote(widget.quoteId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quote Details'),
        actions: [
          BlocBuilder<QuoteBloc, QuoteState>(
            builder: (context, state) {
              if (state is QuoteLoaded) {
                final quote = state.quote;

                // Only show edit button for draft quotes
                if (quote.status == QuoteStatus.draft) {
                  return IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // TODO: Navigate to edit page with quote
                    },
                  );
                }
              }

              return const SizedBox.shrink();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, context),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'preview',
                child: ListTile(
                  leading: Icon(Icons.visibility),
                  title: Text('Preview'),
                ),
              ),
              const PopupMenuItem(
                value: 'generate_pdf',
                child: ListTile(
                  leading: Icon(Icons.picture_as_pdf),
                  title: Text('Generate PDF'),
                ),
              ),
              const PopupMenuItem(
                value: 'send',
                child: ListTile(
                  leading: Icon(Icons.send),
                  title: Text('Send'),
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<QuoteBloc, QuoteState>(
        listener: (context, state) {
          if (state is QuoteError) {
            showDialog(
              context: context,
              builder: (context) => ErrorDialog(message: state.message),
            );
          } else if (state is QuoteOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );

            // Navigate back if quote was deleted
            if (state.message.contains('deleted')) {
              Navigator.pop(context);
            }
          } else if (state is QuoteOperationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is PdfGenerationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text('PDF Generated Successfully'),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        _openPdf(state.pdfUrl);
                      },
                      child: const Text(
                        'VIEW',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                duration: const Duration(seconds: 5),
              ),
            );
          } else if (state is QuoteEmailSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Quote sent successfully')),
            );
          }
        },
        builder: (context, state) {
          if (state is QuotesLoading) {
            return const Center(child: LoadingIndicator());
          } else if (state is QuoteLoaded) {
            final quote = state.quote;
            return _buildQuoteDetails(context, quote);
          } else if (state is QuoteOperationLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(state.operation),
                ],
              ),
            );
          }

          return const Center(child: Text('Quote not found'));
        },
      ),
    );
  }

  Widget _buildQuoteDetails(BuildContext context, Quote quote) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          quote.title,
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildStatusChip(quote.status),
                    ],
                  ),
                  const SizedBox(height: 8.0),

                  // Customer info
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.grey),
                      const SizedBox(width: 8.0),
                      Text(
                        quote.customerName ?? 'Customer ID: ${quote.customerId}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),

                  // Dates
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16.0, color: Colors.grey),
                            const SizedBox(width: 4.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Created', style: TextStyle(color: Colors.grey)),
                                Text(_dateFormat.format(quote.createdAt)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.event, size: 16.0, color: Colors.grey),
                            const SizedBox(width: 4.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Valid Until', style: TextStyle(color: Colors.grey)),
                                Text(_dateFormat.format(quote.validUntil)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Sent date if applicable
                  if (quote.sentAt != null) ...[
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        const Icon(Icons.send, size: 16.0, color: Colors.grey),
                        const SizedBox(width: 4.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Sent', style: TextStyle(color: Colors.grey)),
                            Text(_dateFormat.format(quote.sentAt!)),
                          ],
                        ),
                      ],
                    ),
                  ],

                  // PDF link if available
                  if (quote.pdfUrl != null) ...[
                    const SizedBox(height: 16.0),
                    OutlinedButton.icon(
                      onPressed: () => _openPdf(quote.pdfUrl!),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('View PDF'),
                    ),
                  ],
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
                  const Text(
                    'Items',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8.0),

                  // List of items
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: quote.items.length,
                    itemBuilder: (context, index) {
                      final item = quote.items[index];

                      return QuoteItemTile(
                        item: item,
                        onEdit: quote.status == QuoteStatus.draft
                            ? () {
                          // TODO: Implement editing
                        }
                            : null,
                        onDelete: quote.status == QuoteStatus.draft
                            ? () {
                          // TODO: Implement deletion
                        }
                            : null,
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
                      Text(_currencyFormat.format(quote.subtotal)),
                    ],
                  ),
                  const SizedBox(height: 4.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tax (${quote.taxRate.toStringAsFixed(2)}%):'),
                      Text(_currencyFormat.format(quote.taxAmount)),
                    ],
                  ),
                  const SizedBox(height: 4.0),

                  if (quote.discount > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Discount:'),
                        Text('-${_currencyFormat.format(quote.discount)}'),
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
                        _currencyFormat.format(quote.total),
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

          const SizedBox(height: 16.0),

          // Notes section
          if (quote.notes != null && quote.notes!.isNotEmpty)
            Card(
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
                    Text(quote.notes!),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24.0),

          // Action buttons
          if (quote.status == QuoteStatus.draft) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuotePreviewPage(quote: quote),
                      ),
                    ),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Preview'),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showSendDialog(context, quote),
                    icon: const Icon(Icons.send),
                    label: const Text('Send Quote'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(QuoteStatus status) {
    Color color;
    String label = status.name.toUpperCase();

    switch (status) {
      case QuoteStatus.draft:
        color = Colors.grey;
        break;
      case QuoteStatus.sent:
        color = Colors.blue;
        break;
      case QuoteStatus.accepted:
        color = Colors.green;
        break;
      case QuoteStatus.rejected:
        color = Colors.red;
        break;
      case QuoteStatus.expired:
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _handleMenuAction(String action, BuildContext context) {
    final state = context.read<QuoteBloc>().state;
    if (state is! QuoteLoaded) return;

    final quote = state.quote;

    switch (action) {
      case 'preview':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuotePreviewPage(quote: quote),
          ),
        );
        break;
      case 'generate_pdf':
        context.read<QuoteBloc>().add(GenerateQuotePdf(quote));
        break;
      case 'send':
        _showSendDialog(context, quote);
        break;
      case 'delete':
        _showDeleteConfirmation(context, quote);
        break;
    }
  }

  void _showSendDialog(BuildContext context, Quote quote) {
    // Email text controller
    final emailController = TextEditingController(text: '');
    final messageController = TextEditingController(text: 'Dear ${quote.customerName},\n\nPlease find attached our quote for your review.\n\nBest regards,\nYour Company');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Quote'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              final email = emailController.text.trim();
              final message = messageController.text.trim();

              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter an email address')),
                );
                return;
              }

              Navigator.of(context).pop();

              context.read<QuoteBloc>().add(
                SendQuoteEmail(
                  quote: quote,
                  emailTo: email,
                  message: message,
                ),
              );
            },
            child: const Text('SEND'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Quote quote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quote'),
        content: Text('Are you sure you want to delete this quote?\n\n"${quote.title}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<QuoteBloc>().add(DeleteQuote(quote.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  void _openPdf(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open PDF')),
      );
    }
  }
}