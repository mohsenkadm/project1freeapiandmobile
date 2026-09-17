import 'package:equatable/equatable.dart';

class ReportsSummary extends Equatable {
  const ReportsSummary({
    required this.totalDebtsRemaining,
    required this.totalPayments,
    required this.debtorCustomerCount,
    required this.overdueDebtCount,
    required this.todaysPaymentsCount,
    required this.todaysPaymentsAmount,
    required this.topDebtors,
  });

  final int totalDebtsRemaining;
  final int totalPayments;
  final int debtorCustomerCount;
  final int overdueDebtCount;
  final int todaysPaymentsCount;
  final int todaysPaymentsAmount;
  final List<TopDebtor> topDebtors;

  @override
  List<Object?> get props => [
        totalDebtsRemaining,
        totalPayments,
        debtorCustomerCount,
        overdueDebtCount,
        todaysPaymentsCount,
        todaysPaymentsAmount,
        topDebtors,
      ];
}

class TopDebtor extends Equatable {
  const TopDebtor({
    required this.customerId,
    required this.customerName,
    required this.remaining,
  });

  final String customerId;
  final String customerName;
  final int remaining;

  @override
  List<Object?> get props => [customerId, customerName, remaining];
}
