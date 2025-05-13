// lib/data/models/quote_item.dart
class QuoteItem {
  final String id;
  final String name;
  final String description;
  final double unitPrice;
  final double quantity;
  final String? unit; // e.g., hours, pieces, etc.
  final double total;

  QuoteItem({
    required this.id,
    required this.name,
    required this.description,
    required this.unitPrice,
    required this.quantity,
    this.unit,
    required this.total,
  });

  // Create from map
  factory QuoteItem.fromMap(Map<String, dynamic> map) {
    return QuoteItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'],
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'unit': unit,
      'total': total,
    };
  }

  // Copy with new values
  QuoteItem copyWith({
    String? name,
    String? description,
    double? unitPrice,
    double? quantity,
    String? unit,
  }) {
    final newQuantity = quantity ?? this.quantity;
    final newUnitPrice = unitPrice ?? this.unitPrice;
    final newTotal = newQuantity * newUnitPrice;

    return QuoteItem(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      unitPrice: newUnitPrice,
      quantity: newQuantity,
      unit: unit ?? this.unit,
      total: newTotal,
    );
  }

  // Create new item with calculated total
  static QuoteItem create({
    required String id,
    required String name,
    required String description,
    required double unitPrice,
    required double quantity,
    String? unit,
  }) {
    return QuoteItem(
      id: id,
      name: name,
      description: description,
      unitPrice: unitPrice,
      quantity: quantity,
      unit: unit,
      total: unitPrice * quantity,
    );
  }
}