// lib/data/models/quote.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'quote_item.dart';
import 'customer.dart';

enum QuoteStatus {
  draft,
  sent,
  accepted,
  rejected,
  expired
}

class Quote {
  final String id;
  final String customerId;
  final String? customerName; // Cached for quick access
  final String title;
  final DateTime createdAt;
  final DateTime validUntil;
  final String businessId;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double discount;
  final double total;
  final String? notes;
  final QuoteStatus status;
  final List<QuoteItem> items;
  final String? pdfUrl;
  final DateTime? sentAt;

  Quote({
    required this.id,
    required this.customerId,
    this.customerName,
    required this.title,
    required this.createdAt,
    required this.validUntil,
    required this.businessId,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.discount,
    required this.total,
    this.notes,
    required this.status,
    required this.items,
    this.pdfUrl,
    this.sentAt,
  });

  // Create from Firestore document
  factory Quote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse items
    final itemsList = (data['items'] as List<dynamic>? ?? [])
        .map((item) => QuoteItem.fromMap(item))
        .toList();

    return Quote(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'],
      title: data['title'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      validUntil: (data['validUntil'] as Timestamp).toDate(),
      businessId: data['businessId'] ?? '',
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxRate: (data['taxRate'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (data['taxAmount'] as num?)?.toDouble() ?? 0.0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      notes: data['notes'],
      status: QuoteStatus.values.firstWhere(
            (status) => status.name == (data['status'] ?? 'draft'),
        orElse: () => QuoteStatus.draft,
      ),
      items: itemsList,
      pdfUrl: data['pdfUrl'],
      sentAt: data['sentAt'] != null ? (data['sentAt'] as Timestamp).toDate() : null,
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
      'validUntil': Timestamp.fromDate(validUntil),
      'businessId': businessId,
      'subtotal': subtotal,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'discount': discount,
      'total': total,
      'notes': notes,
      'status': status.name,
      'items': items.map((item) => item.toMap()).toList(),
      'pdfUrl': pdfUrl,
      'sentAt': sentAt != null ? Timestamp.fromDate(sentAt!) : null,
    };
  }

  // Copy with new values
  Quote copyWith({
    String? customerId,
    String? customerName,
    String? title,
    DateTime? validUntil,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? discount,
    double? total,
    String? notes,
    QuoteStatus? status,
    List<QuoteItem>? items,
    String? pdfUrl,
    DateTime? sentAt,
  }) {
    return Quote(
      id: id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      title: title ?? this.title,
      createdAt: createdAt,
      validUntil: validUntil ?? this.validUntil,
      businessId: businessId,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      items: items ?? this.items,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      sentAt: sentAt ?? this.sentAt,
    );
  }

  // Calculate totals
  static Map<String, double> calculateTotals({
    required List<QuoteItem> items,
    required double taxRate,
    required double discount,
  }) {
    final subtotal = items.fold(0.0, (sum, item) => sum + (item.quantity * item.unitPrice));
    final taxAmount = subtotal * (taxRate / 100);
    final total = subtotal + taxAmount - discount;

    return {
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'total': total,
    };
  }
}