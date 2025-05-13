// lib/presentation/blocs/quote/quote_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'quote_event.dart';
import 'quote_state.dart';
import '../../../domain/repositories/quote_repository.dart';
import '../../../data/models/quote.dart';
import '../../../data/models/quote_item.dart';

class QuoteBloc extends Bloc<QuoteEvent, QuoteState> {
  final QuoteRepository _quoteRepository;
  StreamSubscription<List<Quote>>? _quotesSubscription;

  QuoteBloc({required QuoteRepository quoteRepository})
      : _quoteRepository = quoteRepository,
        super(QuoteInitial()) {
    on<LoadQuotes>(_onLoadQuotes);
    on<LoadQuotesByCustomer>(_onLoadQuotesByCustomer);
    on<LoadQuote>(_onLoadQuote);
    on<AddQuote>(_onAddQuote);
    on<UpdateQuote>(_onUpdateQuote);
    on<DeleteQuote>(_onDeleteQuote);
    on<GenerateQuotePdf>(_onGenerateQuotePdf);
    on<SendQuoteEmail>(_onSendQuoteEmail);
    on<AddQuoteItem>(_onAddQuoteItem);
    on<UpdateQuoteItem>(_onUpdateQuoteItem);
    on<DeleteQuoteItem>(_onDeleteQuoteItem);
  }

  Future<void> _onLoadQuotes(LoadQuotes event, Emitter<QuoteState> emit) async {
    emit(QuotesLoading());
    try {
      await _quotesSubscription?.cancel();
      _quotesSubscription = _quoteRepository.getQuotes().listen(
            (quotes) => add(QuotesLoaded(quotes) as QuoteEvent),
        onError: (error) => add(QuoteError(error.toString()) as QuoteEvent),
      );
    } catch (e) {
      emit(QuoteError(e.toString()));
    }
  }

  Future<void> _onLoadQuotesByCustomer(LoadQuotesByCustomer event, Emitter<QuoteState> emit) async {
    emit(QuotesLoading());
    try {
      await _quotesSubscription?.cancel();
      _quotesSubscription = _quoteRepository.getQuotesByCustomer(event.customerId).listen(
            (quotes) => emit(QuotesLoaded(quotes)),
        onError: (error) => emit(QuoteError(error.toString())),
      );
    } catch (e) {
      emit(QuoteError(e.toString()));
    }
  }

  Future<void> _onLoadQuote(LoadQuote event, Emitter<QuoteState> emit) async {
    emit(QuotesLoading());
    try {
      final quote = await _quoteRepository.getQuote(event.id);
      emit(QuoteLoaded(quote));
    } catch (e) {
      emit(QuoteError(e.toString()));
    }
  }

  Future<void> _onAddQuote(AddQuote event, Emitter<QuoteState> emit) async {
    emit(const QuoteOperationLoading('Creating quote'));
    try {
      await _quoteRepository.addQuote(event.quote);
      emit(QuoteOperationSuccess(
        message: 'Quote created successfully',
        quote: event.quote,
      ));
    } catch (e) {
      emit(QuoteOperationFailure('Failed to create quote: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateQuote(UpdateQuote event, Emitter<QuoteState> emit) async {
    emit(const QuoteOperationLoading('Updating quote'));
    try {
      await _quoteRepository.updateQuote(event.quote);
      emit(QuoteOperationSuccess(
        message: 'Quote updated successfully',
        quote: event.quote,
      ));
    } catch (e) {
      emit(QuoteOperationFailure('Failed to update quote: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteQuote(DeleteQuote event, Emitter<QuoteState> emit) async {
    emit(const QuoteOperationLoading('Deleting quote'));
    try {
      await _quoteRepository.deleteQuote(event.id);
      emit(const QuoteOperationSuccess(message: 'Quote deleted successfully'));
    } catch (e) {
      emit(QuoteOperationFailure('Failed to delete quote: ${e.toString()}'));
    }
  }

  Future<void> _onGenerateQuotePdf(GenerateQuotePdf event, Emitter<QuoteState> emit) async {
    emit(const QuoteOperationLoading('Generating PDF'));
    try {
      final pdfUrl = await _quoteRepository.generatePdf(event.quote);
      if (pdfUrl != null) {
        final updatedQuote = event.quote.copyWith(pdfUrl: pdfUrl);
        emit(PdfGenerationSuccess(
          pdfUrl: pdfUrl,
          quote: updatedQuote,
        ));
      } else {
        emit(const QuoteOperationFailure('Failed to generate PDF'));
      }
    } catch (e) {
      emit(QuoteOperationFailure('Failed to generate PDF: ${e.toString()}'));
    }
  }

  Future<void> _onSendQuoteEmail(SendQuoteEmail event, Emitter<QuoteState> emit) async {
    emit(const QuoteOperationLoading('Sending quote via email'));
    try {
      await _quoteRepository.sendQuoteEmail(
        event.quote,
        event.emailTo,
        event.message,
      );

      // Create updated quote with sent status
      final updatedQuote = event.quote.copyWith(
        status: QuoteStatus.sent,
        sentAt: DateTime.now(),
      );

      emit(QuoteEmailSent(updatedQuote));
    } catch (e) {
      emit(QuoteOperationFailure('Failed to send email: ${e.toString()}'));
    }
  }

  Future<void> _onAddQuoteItem(AddQuoteItem event, Emitter<QuoteState> emit) async {
    try {
      // Add the new item to the quote's items list
      final newItems = List<QuoteItem>.from(event.quote.items)..add(event.item);

      // Recalculate totals
      final totals = Quote.calculateTotals(
        items: newItems,
        taxRate: event.quote.taxRate,
        discount: event.quote.discount,
      );

      // Create updated quote
      final updatedQuote = event.quote.copyWith(
        items: newItems,
        subtotal: totals['subtotal']!,
        taxAmount: totals['taxAmount']!,
        total: totals['total']!,
      );

      // Update in database
      add(UpdateQuote(updatedQuote));
    } catch (e) {
      emit(QuoteOperationFailure('Failed to add item: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateQuoteItem(UpdateQuoteItem event, Emitter<QuoteState> emit) async {
    try {
      // Find and update the item in the quote's items list
      final updatedItems = event.quote.items.map((item) {
        if (item.id == event.item.id) {
          return event.item;
        }
        return item;
      }).toList();

      // Recalculate totals
      final totals = Quote.calculateTotals(
        items: updatedItems,
        taxRate: event.quote.taxRate,
        discount: event.quote.discount,
      );

      // Create updated quote
      final updatedQuote = event.quote.copyWith(
        items: updatedItems,
        subtotal: totals['subtotal']!,
        taxAmount: totals['taxAmount']!,
        total: totals['total']!,
      );

      // Update in database
      add(UpdateQuote(updatedQuote));
    } catch (e) {
      emit(QuoteOperationFailure('Failed to update item: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteQuoteItem(DeleteQuoteItem event, Emitter<QuoteState> emit) async {
    try {
      // Remove the item from the quote's items list
      final updatedItems = event.quote.items.where((item) => item.id != event.itemId).toList();

      // Recalculate totals
      final totals = Quote.calculateTotals(
        items: updatedItems,
        taxRate: event.quote.taxRate,
        discount: event.quote.discount,
      );

      // Create updated quote
      final updatedQuote = event.quote.copyWith(
        items: updatedItems,
        subtotal: totals['subtotal']!,
        taxAmount: totals['taxAmount']!,
        total: totals['total']!,
      );

      // Update in database
      add(UpdateQuote(updatedQuote));
    } catch (e) {
      emit(QuoteOperationFailure('Failed to delete item: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _quotesSubscription?.cancel();
    return super.close();
  }
}