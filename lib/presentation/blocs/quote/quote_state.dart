// lib/presentation/blocs/quote/quote_state.dart
import 'package:equatable/equatable.dart';
import '../../../data/models/quote.dart';

abstract class QuoteState extends Equatable {
  const QuoteState();

  @override
  List<Object?> get props => [];
}

class QuoteInitial extends QuoteState {}

class QuotesLoading extends QuoteState {}

class QuotesLoaded extends QuoteState {
  final List<Quote> quotes;

  const QuotesLoaded(this.quotes);

  @override
  List<Object> get props => [quotes];
}

class QuoteLoaded extends QuoteState {
  final Quote quote;

  const QuoteLoaded(this.quote);

  @override
  List<Object> get props => [quote];
}

class QuoteError extends QuoteState {
  final String message;

  const QuoteError(this.message);

  @override
  List<Object> get props => [message];
}

class QuoteOperationLoading extends QuoteState {
  final String operation;

  const QuoteOperationLoading(this.operation);

  @override
  List<Object> get props => [operation];
}

class QuoteOperationSuccess extends QuoteState {
  final String message;
  final Quote? quote;

  const QuoteOperationSuccess({
    required this.message,
    this.quote,
  });

  @override
  List<Object?> get props => [message, quote];
}

class QuoteOperationFailure extends QuoteState {
  final String message;

  const QuoteOperationFailure(this.message);

  @override
  List<Object> get props => [message];
}

class PdfGenerationSuccess extends QuoteState {
  final String pdfUrl;
  final Quote quote;

  const PdfGenerationSuccess({
    required this.pdfUrl,
    required this.quote,
  });

  @override
  List<Object> get props => [pdfUrl, quote];
}

class QuoteEmailSent extends QuoteState {
  final Quote quote;

  const QuoteEmailSent(this.quote);

  @override
  List<Object> get props => [quote];
}