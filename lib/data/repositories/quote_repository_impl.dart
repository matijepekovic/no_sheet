// lib/data/repositories/quote_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

import '../../domain/repositories/quote_repository.dart';
import '../models/quote.dart';
import '../models/customer.dart';
import '../../core/services/pdf_service.dart';

class QuoteRepositoryImpl implements QuoteRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final String _userId;
  final PdfService _pdfService;

  QuoteRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required String userId,
    required PdfService pdfService,
  }) : _firestore = firestore,
        _storage = storage,
        _userId = userId,
        _pdfService = pdfService;

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _quotesCollection =>
      _firestore.collection('quotes');

  CollectionReference<Map<String, dynamic>> get _customersCollection =>
      _firestore.collection('customers');

  @override
  Stream<List<Quote>> getQuotes() {
    return _quotesCollection
        .where('businessId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Quote.fromFirestore(doc))
        .toList());
  }

  @override
  Stream<List<Quote>> getQuotesByCustomer(String customerId) {
    return _quotesCollection
        .where('businessId', isEqualTo: _userId)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Quote.fromFirestore(doc))
        .toList());
  }

  @override
  Future<Quote> getQuote(String id) async {
    final doc = await _quotesCollection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Quote not found');
    }
    return Quote.fromFirestore(doc);
  }

  @override
  Future<void> addQuote(Quote quote) async {
    await _quotesCollection.doc(quote.id).set(quote.toMap());
  }

  @override
  Future<void> updateQuote(Quote quote) async {
    await _quotesCollection.doc(quote.id).update(quote.toMap());
  }

  @override
  Future<void> deleteQuote(String id) async {
    // First try to delete any associated PDF
    final quote = await getQuote(id);
    if (quote.pdfUrl != null) {
      try {
        // Parse the URL to get the path in Firebase Storage
        final ref = _storage.refFromURL(quote.pdfUrl!);
        await ref.delete();
      } catch (e) {
        // Log but continue with deletion of the quote
        print('Error deleting PDF: $e');
      }
    }

    // Delete the quote
    await _quotesCollection.doc(id).delete();
  }

  @override
  Future<String?> generatePdf(Quote quote) async {
    try {
      // Get customer details
      final customerDoc = await _customersCollection.doc(quote.customerId).get();
      if (!customerDoc.exists) {
        throw Exception('Customer not found');
      }
      final customer = Customer.fromFirestore(customerDoc);

      // Generate PDF bytes
      final pdfBytes = await _pdfService.generateQuotePdf(quote, customer);

      // Upload to Firebase Storage
      final fileName = 'quotes/${_userId}/${quote.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final ref = _storage.ref().child(fileName);

      // Upload
      await ref.putData(pdfBytes);

      // Get download URL
      final downloadUrl = await ref.getDownloadURL();

      // Update quote with PDF URL
      final updatedQuote = quote.copyWith(pdfUrl: downloadUrl);
      await updateQuote(updatedQuote);

      return downloadUrl;
    } catch (e) {
      print('Error generating PDF: $e');
      return null;
    }
  }

  @override
  Future<void> sendQuoteEmail(Quote quote, String emailTo, String message) async {
    // Generate PDF if not already generated
    if (quote.pdfUrl == null) {
      final pdfUrl = await generatePdf(quote);
      if (pdfUrl == null) {
        throw Exception('Failed to generate PDF');
      }
    }

    // Use a Cloud Function or a email service API to send the email with the PDF attachment
    // This would be implemented based on your email service provider
    // For now, we'll just mark the quote as sent and update the sentAt timestamp

    final updatedQuote = quote.copyWith(
      status: QuoteStatus.sent,
      sentAt: DateTime.now(),
    );

    await updateQuote(updatedQuote);

    // Note: In a real implementation, you would trigger a Cloud Function
    // or call an API to send the actual email with the PDF attachment
  }
}