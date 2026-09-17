import 'package:equatable/equatable.dart';

class Debt extends Equatable {
  const Debt({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.description,
    this.dueDate,
    this.notes,
    required this.createdAt,
  });

  final String id;
  final String customerId;
  final int amount;
  final String description;
  final DateTime? dueDate;
  final String? notes;
  final DateTime createdAt;

  @override
  List<Object?> get props =>
      [id, customerId, amount, description, dueDate, notes, createdAt];
}
