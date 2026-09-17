import 'package:equatable/equatable.dart';

import 'customer.dart';

enum CustomerDebtStatus { noDebt, hasDebt, settled, overdue }

class CustomerBalance extends Equatable {
  const CustomerBalance({
    required this.customerId,
    required this.totalDebts,
    required this.totalPayments,
  });

  final String customerId;
  final int totalDebts;
  final int totalPayments;

  int get remaining => totalDebts - totalPayments;

  bool get hasDebt => remaining > 0;
  bool get isSettled => totalDebts > 0 && remaining == 0;
  bool get hasNoDebtHistory => totalDebts == 0 && totalPayments == 0;

  @override
  List<Object?> get props => [customerId, totalDebts, totalPayments];
}

class CustomerListItem extends Equatable {
  const CustomerListItem({
    required this.customer,
    required this.balance,
    this.lastActivityAt,
    this.hasOverdueDebt = false,
  });

  final Customer customer;
  final CustomerBalance balance;
  final DateTime? lastActivityAt;
  final bool hasOverdueDebt;

  CustomerDebtStatus get status {
    if (hasOverdueDebt && balance.hasDebt) return CustomerDebtStatus.overdue;
    if (balance.hasDebt) return CustomerDebtStatus.hasDebt;
    if (balance.isSettled) return CustomerDebtStatus.settled;
    return CustomerDebtStatus.noDebt;
  }

  @override
  List<Object?> get props =>
      [customer, balance, lastActivityAt, hasOverdueDebt];
}
