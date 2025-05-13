// lib/data/models/project.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum ProjectStatus {
  notStarted,
  inProgress,
  onHold,
  completed,
  cancelled
}

class Project {
  final String id;
  final String customerId;
  final String? customerName;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final String businessId;
  final ProjectStatus status;
  final double budget;
  final List<String>? imageUrls;
  final String? location;
  final String? notes;

  Project({
    required this.id,
    required this.customerId,
    this.customerName,
    required this.title,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.businessId,
    required this.status,
    required this.budget,
    this.imageUrls,
    this.location,
    this.notes,
  });

  // From Firestore
  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Project(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null ? (data['endDate'] as Timestamp).toDate() : null,
      businessId: data['businessId'] ?? '',
      status: ProjectStatus.values.firstWhere(
            (status) => status.name == (data['status'] ?? 'notStarted'),
        orElse: () => ProjectStatus.notStarted,
      ),
      budget: (data['budget'] as num?)?.toDouble() ?? 0.0,
      imageUrls: (data['imageUrls'] as List<dynamic>?)?.map((url) => url.toString()).toList(),
      location: data['location'],
      notes: data['notes'],
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'businessId': businessId,
      'status': status.name,
      'budget': budget,
      'imageUrls': imageUrls,
      'location': location,
      'notes': notes,
    };
  }

  // Copy with
  Project copyWith({
    String? customerId,
    String? customerName,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    ProjectStatus? status,
    double? budget,
    List<String>? imageUrls,
    String? location,
    String? notes,
  }) {
    return Project(
      id: id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      businessId: businessId,
      status: status ?? this.status,
      budget: budget ?? this.budget,
      imageUrls: imageUrls ?? this.imageUrls,
      location: location ?? this.location,
      notes: notes ?? this.notes,
    );
  }
}