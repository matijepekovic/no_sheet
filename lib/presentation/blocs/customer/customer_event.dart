// lib/presentation/blocs/customer/customer_event.dart
import 'package:equatable/equatable.dart';
import '../../../data/models/customer.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomers extends CustomerEvent {}

class LoadCustomer extends CustomerEvent {
  final String id;

  const LoadCustomer(this.id);

  @override
  List<Object> get props => [id];
}

class AddCustomer extends CustomerEvent {
  final Customer customer;

  const AddCustomer(this.customer);

  @override
  List<Object> get props => [customer];
}

class UpdateCustomer extends CustomerEvent {
  final Customer customer;

  const UpdateCustomer(this.customer);

  @override
  List<Object> get props => [customer];
}

class DeleteCustomer extends CustomerEvent {
  final String id;

  const DeleteCustomer(this.id);

  @override
  List<Object> get props => [id];
}