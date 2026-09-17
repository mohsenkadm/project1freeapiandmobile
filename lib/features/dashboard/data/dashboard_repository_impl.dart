import '../../../core/database/app_database.dart';
import '../../customers/domain/entities/customer.dart';
import '../../debts/domain/entities/debt.dart';
import '../domain/entities/dashboard_summary.dart';
import '../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<DashboardSummary> getSummary() async {
    final customers = await _db.select(_db.customers).get();
    final debts = await _db.select(_db.debts).get();
    final payments = await _db.select(_db.payments).get();

    final totalDebts = debts.fold<int>(0, (s, d) => s + d.amount);
    final totalPayments = payments.fold<int>(0, (s, p) => s + p.amount);
    final remaining = totalDebts - totalPayments;

    final balances = <String, int>{};
    for (final d in debts) {
      balances[d.customerId] = (balances[d.customerId] ?? 0) + d.amount;
    }
    for (final p in payments) {
      balances[p.customerId] = (balances[p.customerId] ?? 0) - p.amount;
    }
    final withDebt = balances.values.where((v) => v > 0).length;

    final start = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final todayPayments =
        payments.where((p) => !p.createdAt.isBefore(start)).toList();

    final customerMap = {
      for (final c in customers)
        c.id: Customer(
          id: c.id,
          name: c.name,
          phone: c.phone,
          notes: c.notes,
          createdAt: c.createdAt,
          updatedAt: c.updatedAt,
        ),
    };

    final recent = [...debts]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recentItems = recent.take(8).map((d) {
      final customer = customerMap[d.customerId];
      if (customer == null) return null;
      return RecentDebtItem(
        debt: Debt(
          id: d.id,
          customerId: d.customerId,
          amount: d.amount,
          description: d.description,
          dueDate: d.dueDate,
          notes: d.notes,
          createdAt: d.createdAt,
        ),
        customer: customer,
      );
    }).whereType<RecentDebtItem>().toList();

    return DashboardSummary(
      totalDebtsRemaining: remaining < 0 ? 0 : remaining,
      customerCount: customers.length,
      customersWithDebt: withDebt,
      todaysPaymentsCount: todayPayments.length,
      todaysPaymentsAmount:
          todayPayments.fold<int>(0, (s, p) => s + p.amount),
      recentDebts: recentItems,
    );
  }

  @override
  Stream<DashboardSummary> watchSummary() {
    return _db.select(_db.customers).watch().asyncMap((_) => getSummary());
  }
}
