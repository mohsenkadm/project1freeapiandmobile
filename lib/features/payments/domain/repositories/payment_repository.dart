import '../entities/payment.dart';

abstract class PaymentRepository {
  Future<Payment> addPayment({
    required String customerId,
    required int amount,
    required PaymentMethod paymentMethod,
    String? debtId,
    String? notes,
  });

  Future<List<Payment>> getByCustomer(String customerId);

  Future<Payment?> getLastPayment(String customerId);

  Future<int> todaysPaymentsCount();

  Future<int> todaysPaymentsAmount();

  Future<void> deletePayment(String id);
}
