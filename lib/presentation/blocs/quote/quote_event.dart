// lib/presentation/blocs/quote/quote_event.dart
import 'package:equatable/equatable.dart';
import '../../../data/models/quote.dart';
import '../../../data/models/quote_item.dart';

abstract class QuoteEvent extends Equatable {
  const QuoteEvent();

  @override
  List<Object?> get props => [];
}

class LoadQuotes extends QuoteEvent {}

class LoadQuotesByCustomer extends QuoteEvent {
  final String customerId;

  const LoadQuotesByCustomer(this.customerId);

  @override
  List<Object> get props => [customerId];
}

class LoadQuote extends QuoteEvent {
  final String id;

  const LoadQuote(this.id);

  @override
  List<Object> get props => [id];
}

class AddQuote extends QuoteEvent {
  final Quote quote;

  const AddQuote(this.quote);

  @override
  List<Object> get props => [quote];
}

class UpdateQuote extends QuoteEvent {
  final Quote quote;

  const UpdateQuote(this.quote);

  @override
  List<Object> get props => [quote];
}

class DeleteQuote extends QuoteEvent {
  final String id;

  const DeleteQuote(this.id);

  @override
  List<Object> get props => [id];
}

class GenerateQuotePdf extends QuoteEvent {
  final Quote quote;

  const GenerateQuotePdf(this.quote);

  @override
  List<Object> get props => [quote];
}

class SendQuoteEmail extends QuoteEvent {
  final Quote quote;
  final String emailTo;
  final String message;

  const SendQuoteEmail({
    required this.quote,
    required this.emailTo,
    required this.message,
  });

  @override
  List<Object> get props => [quote, emailTo, message];
}

class AddQuoteItem extends QuoteEvent {
  final Quote quote;
  final QuoteItem item;

  const AddQuoteItem({
    required this.quote,
    required this.item,
  });

  @override
  List<Object> get props => [quote, item];
}

class UpdateQuoteItem extends QuoteEvent {
  final Quote quote;
  final QuoteItem item;

  const UpdateQuoteItem({
    required this.quote,
    required this.item,
  });

  @override
  List<Object> get props => [quote, item];
}

class DeleteQuoteItem extends QuoteEvent {
  final Quote quote;
  final String itemId;

  const DeleteQuoteItem({
    required this.quote,
    required this.itemId,
  });

  @override
  List<Object> get props => [quote, itemId];
}