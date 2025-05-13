import '../../../data/models/customer.dart';// lib/presentation/blocs/customer/customer_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'customer_event.dart';
import 'customer_state.dart';
import '../../../domain/repositories/customer_repository.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository _customerRepository;
  StreamSubscription<List<Customer>>? _customersSubscription;

  CustomerBloc({required CustomerRepository customerRepository})
      : _customerRepository = customerRepository,
        super(CustomersInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<LoadCustomer>(_onLoadCustomer);
    on<AddCustomer>(_onAddCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
  }

  Future<void> _onLoadCustomers(
      LoadCustomers event,
      Emitter<CustomerState> emit,
      ) async {
    emit(CustomersLoading());
    try {
      await _customersSubscription?.cancel();
      _customersSubscription = _customerRepository.getCustomers().listen(
            (customers) => add(CustomersLoaded(customers) as CustomerEvent),
        onError: (error) => add(CustomerError(error.toString()) as CustomerEvent),
      );
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onLoadCustomer(
      LoadCustomer event,
      Emitter<CustomerState> emit,
      ) async {
    emit(CustomersLoading());
    try {
      final customer = await _customerRepository.getCustomer(event.id);
      emit(CustomerLoaded(customer));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onAddCustomer(
      AddCustomer event,
      Emitter<CustomerState> emit,
      ) async {
    try {
      await _customerRepository.addCustomer(event.customer);
      emit(const CustomerOperationSuccess('Customer added successfully'));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onUpdateCustomer(
      UpdateCustomer event,
      Emitter<CustomerState> emit,
      ) async {
    try {
      await _customerRepository.updateCustomer(event.customer);
      emit(const CustomerOperationSuccess('Customer updated successfully'));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onDeleteCustomer(
      DeleteCustomer event,
      Emitter<CustomerState> emit,
      ) async {
    try {
      await _customerRepository.deleteCustomer(event.id);
      emit(const CustomerOperationSuccess('Customer deleted successfully'));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _customersSubscription?.cancel();
    return super.close();
  }
}