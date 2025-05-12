import '../../data/models/customer.dart';

abstract class CustomerRepository {
  Stream<List<Customer>> getCustomers();
  Future<Customer> getCustomer(String id);
  Future<void> addCustomer(Customer customer);
  Future<void> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String id);
}