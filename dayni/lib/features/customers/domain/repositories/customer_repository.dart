import '../entities/customer.dart';
import '../entities/customer_balance.dart';
import '../entities/timeline_entry.dart';

abstract class CustomerRepository {
  Stream<List<CustomerListItem>> watchCustomers({
    String? query,
    CustomerDebtStatus? filter,
  });

  Future<Customer?> getById(String id);

  Stream<Customer?> watchById(String id);

  Future<CustomerBalance> getBalance(String customerId);

  Stream<CustomerBalance> watchBalance(String customerId);

  Future<List<TimelineEntry>> getTimeline(String customerId);

  Stream<List<TimelineEntry>> watchTimeline(String customerId);

  Future<Customer> addCustomer({
    required String name,
    String? phone,
    String? notes,
  });

  Future<Customer> updateCustomer(Customer customer);

  Future<void> deleteCustomer(String id);

  Future<int> count();
}
