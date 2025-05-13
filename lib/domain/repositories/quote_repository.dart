
// lib/domain/repositories/quote_repository.dart
import '../../data/models/quote.dart';

abstract class QuoteRepository {
  Stream<List<Quote>> getQuotes();
  Stream<List<Quote>> getQuotesByCustomer(String customerId);
  Future<Quote> getQuote(String id);
  Future<void> addQuote(Quote quote);
  Future<void> updateQuote(Quote quote);
  Future<void> deleteQuote(String id);
  Future<String?> generatePdf(Quote quote);
  Future<void> sendQuoteEmail(Quote quote, String emailTo, String message);
}