import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/date_formatter.dart';
import '../domain/entities/reports_summary.dart';
import '../domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<ReportsSummary> getSummary() async {
    final customers = await _db.select(_db.customers).get();
    final debts = await _db.select(_db.debts).get();
    final payments = await _db.select(_db.payments).get();

    final totalDebts = debts.fold<int>(0, (s, d) => s + d.amount);
    final totalPayments = payments.fold<int>(0, (s, p) => s + p.amount);
    final remaining = (totalDebts - totalPayments).clamp(0, totalDebts);

    final balances = <String, int>{};
    for (final d in debts) {
      balances[d.customerId] = (balances[d.customerId] ?? 0) + d.amount;
    }
    for (final p in payments) {
      balances[p.customerId] = (balances[p.customerId] ?? 0) - p.amount;
    }

    final debtorCount = balances.values.where((v) => v > 0).length;

    final overdueCount = debts.where((d) {
      if (!DateFormatter.isOverdue(d.dueDate)) return false;
      return (balances[d.customerId] ?? 0) > 0;
    }).length;

    final start = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final todayPayments =
        payments.where((p) => !p.createdAt.isBefore(start)).toList();

    final nameMap = {for (final c in customers) c.id: c.name};
    final top = balances.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topDebtors = top
        .take(AppConstants.topDebtorsLimit)
        .map(
          (e) => TopDebtor(
            customerId: e.key,
            customerName: nameMap[e.key] ?? '',
            remaining: e.value,
          ),
        )
        .toList();

    return ReportsSummary(
      totalDebtsRemaining: remaining,
      totalPayments: totalPayments,
      debtorCustomerCount: debtorCount,
      overdueDebtCount: overdueCount,
      todaysPaymentsCount: todayPayments.length,
      todaysPaymentsAmount:
          todayPayments.fold<int>(0, (s, p) => s + p.amount),
      topDebtors: topDebtors,
    );
  }

  @override
  Stream<ReportsSummary> watchSummary() {
    return _db.select(_db.customers).watch().asyncMap((_) => getSummary());
  }
}
