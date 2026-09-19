import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

enum TransactionType {
  sale,
  expense,
  payment,
  withdrawal,
}

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required TransactionType type,
    required double amount,
    required String description,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}

extension TransactionTypeX on TransactionType {
  String get arabicLabel {
    switch (this) {
      case TransactionType.sale:
        return 'مبيعات';
      case TransactionType.expense:
        return 'مصروف';
      case TransactionType.payment:
        return 'دفعة';
      case TransactionType.withdrawal:
        return 'سحب';
    }
  }

  bool get isIncome => this == TransactionType.sale;

  String get addSheetTitle {
    switch (this) {
      case TransactionType.sale:
        return 'إضافة مبيعات';
      case TransactionType.expense:
        return 'إضافة مصروف';
      case TransactionType.payment:
        return 'إضافة دفعة';
      case TransactionType.withdrawal:
        return 'إضافة سحب';
    }
  }
}
