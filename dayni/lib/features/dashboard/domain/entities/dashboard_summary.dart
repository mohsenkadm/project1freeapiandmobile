import 'package:equatable/equatable.dart';

import '../../../customers/domain/entities/customer.dart';
import '../../../debts/domain/entities/debt.dart';

class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.totalDebtsRemaining,
    required this.customerCount,
    required this.customersWithDebt,
    required this.todaysPaymentsCount,
    required this.todaysPaymentsAmount,
    required this.recentDebts,
  });

  final int totalDebtsRemaining;
  final int customerCount;
  final int customersWithDebt;
  final int todaysPaymentsCount;
  final int todaysPaymentsAmount;
  final List<RecentDebtItem> recentDebts;

  @override
  List<Object?> get props => [
        totalDebtsRemaining,
        customerCount,
        customersWithDebt,
        todaysPaymentsCount,
        todaysPaymentsAmount,
        recentDebts,
      ];
}

class RecentDebtItem extends Equatable {
  const RecentDebtItem({
    required this.debt,
    required this.customer,
  });

  final Debt debt;
  final Customer customer;

  @override
  List<Object?> get props => [debt, customer];
}
