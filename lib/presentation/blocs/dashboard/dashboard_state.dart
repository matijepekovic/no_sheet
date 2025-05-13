// lib/presentation/blocs/dashboard/dashboard_state.dart
import 'package:equatable/equatable.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final int customerCount;
  final int quoteCount;
  final int projectCount;
  final int productCount;
  final List<dynamic> recentActivities;

  const DashboardLoaded({
    required this.customerCount,
    required this.quoteCount,
    required this.projectCount,
    required this.productCount,
    required this.recentActivities,
  });

  @override
  List<Object?> get props => [
    customerCount,
    quoteCount,
    projectCount,
    productCount,
    recentActivities
  ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}