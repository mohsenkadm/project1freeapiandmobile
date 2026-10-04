import 'package:equatable/equatable.dart';

enum PaymentMethod { cash, transfer, other }

class Payment extends Equatable {
  const Payment({
    required this.id,
    required this.customerId,
    this.debtId,
    required this.amount,
    required this.paymentMethod,
    this.notes,
    required this.createdAt,
  });

  final String id;
  final String customerId;
  final String? debtId;
  final int amount;
  final PaymentMethod paymentMethod;
  final String? notes;
  final DateTime createdAt;

  @override
  List<Object?> get props =>
      [id, customerId, debtId, amount, paymentMethod, notes, createdAt];
}
