// lib/presentation/pages/quotes/quotes_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../data/models/quote.dart';
import '../../blocs/quote/quote_bloc.dart';
import '../../blocs/quote/quote_event.dart';
import '../../blocs/quote/quote_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/quote/quote_summary.dart';
import 'create_quote_page.dart';
import 'quote_detail_page.dart';

class QuotesPage extends StatefulWidget {
  final bool selectionMode;

  const QuotesPage({Key? key, this.selectionMode = false}) : super(key: key);

  @override
  State<QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    // Load quotes when page initializes
    context.read<QuoteBloc>().add(LoadQuotes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.selectionMode ? AppBar(
        title: const Text('Select Quote'),
      ) : null,
      body: Column(
        children: [
          // Search bar
          if (!widget.selectionMode)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search quotes...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.isNotEmpty ? value : null;
                  });
                },
              ),
            ),

          // Quotes list
          Expanded(
            child: BlocBuilder<QuoteBloc, QuoteState>(
              builder: (context, state) {
                if (state is QuotesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is QuotesLoaded) {
                  final quotes = state.quotes;

                  // Filter quotes based on search
                  final filteredQuotes = _searchQuery != null
                      ? quotes.where((quote) =>
                  quote.title.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
                      (quote.customerName?.toLowerCase().contains(_searchQuery!.toLowerCase()) ?? false))
                      .toList()
                      : quotes;

                  if (filteredQuotes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.description_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery != null
                                ? 'No quotes found matching "$_searchQuery"'
                                : 'No quotes yet',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          if (_searchQuery != null)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _searchQuery = null;
                                });
                              },
                              child: const Text('Clear Search'),
                            ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filteredQuotes.length,
                    itemBuilder: (context, index) {
                      final quote = filteredQuotes[index];

                      return QuoteSummary(
                        quote: quote,
                        showActions: true,
                        onViewDetails: () {
                          if (widget.selectionMode) {
                            Navigator.pop(context, quote);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuoteDetailPage(quoteId: quote.id),
                              ),
                            );
                          }
                        },
                        onSend: quote.status == QuoteStatus.draft
                            ? () {
                          // Show send dialog
                        }
                            : null,
                      );
                    },
                  );
                } else if (state is QuoteError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<QuoteBloc>().add(LoadQuotes());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      floatingActionButton: !widget.selectionMode ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateQuotePage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ) : null,
    );
  }
}