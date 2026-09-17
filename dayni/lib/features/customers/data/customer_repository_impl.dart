import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/date_formatter.dart';
import '../domain/entities/customer.dart';
import '../domain/entities/customer_balance.dart';
import '../domain/entities/timeline_entry.dart';
import '../domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  Customer _map(CustomerRow row) => Customer(
        id: row.id,
        name: row.name,
        phone: row.phone,
        notes: row.notes,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  @override
  Future<Customer> addCustomer({
    required String name,
    String? phone,
    String? notes,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    await _db.into(_db.customers).insert(
          CustomersCompanion.insert(
            id: id,
            name: name,
            phone: Value(phone),
            notes: Value(notes),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return (await getById(id))!;
  }

  @override
  Future<int> count() async {
    final countExp = _db.customers.id.count();
    final query = _db.selectOnly(_db.customers)..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await (_db.delete(_db.payments)..where((t) => t.customerId.equals(id)))
        .go();
    await (_db.delete(_db.debts)..where((t) => t.customerId.equals(id))).go();
    await (_db.delete(_db.customers)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<Customer?> getById(String id) async {
    final row = await (_db.select(_db.customers)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _map(row);
  }

  @override
  Stream<Customer?> watchById(String id) {
    return (_db.select(_db.customers)..where((t) => t.id.equals(id)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _map(row));
  }

  @override
  Future<CustomerBalance> getBalance(String customerId) async {
    final debtSum = _db.debts.amount.sum();
    final debtQuery = _db.selectOnly(_db.debts)
      ..addColumns([debtSum])
      ..where(_db.debts.customerId.equals(customerId));
    final debtRow = await debtQuery.getSingle();
    final totalDebts = debtRow.read(debtSum) ?? 0;

    final paySum = _db.payments.amount.sum();
    final payQuery = _db.selectOnly(_db.payments)
      ..addColumns([paySum])
      ..where(_db.payments.customerId.equals(customerId));
    final payRow = await payQuery.getSingle();
    final totalPayments = payRow.read(paySum) ?? 0;

    return CustomerBalance(
      customerId: customerId,
      totalDebts: totalDebts,
      totalPayments: totalPayments,
    );
  }

  @override
  Stream<CustomerBalance> watchBalance(String customerId) {
    return _db
        .select(_db.debts)
        .watch()
        .asyncMap((_) => getBalance(customerId))
        .asyncExpand(
          (balance) => _db
              .select(_db.payments)
              .watch()
              .take(1)
              .asyncMap((_) async => balance),
        );
  }

  /// Reactive balance that refreshes when debts or payments change.
  Stream<CustomerBalance> watchBalanceLive(String customerId) async* {
    yield await getBalance(customerId);
    await for (final _ in _mergedChanges()) {
      yield await getBalance(customerId);
    }
  }

  Stream<void> _mergedChanges() async* {
    await for (final _ in _db.select(_db.debts).watch()) {
      yield null;
    }
  }

  @override
  Future<List<TimelineEntry>> getTimeline(String customerId) async {
    final debts = await (_db.select(_db.debts)
          ..where((t) => t.customerId.equals(customerId)))
        .get();
    final payments = await (_db.select(_db.payments)
          ..where((t) => t.customerId.equals(customerId)))
        .get();

    final entries = <TimelineEntry>[
      ...debts.map(
        (d) => TimelineEntry(
          id: d.id,
          type: TimelineEntryType.debt,
          amount: d.amount,
          title: 'دين جديد',
          subtitle: d.description.isEmpty ? null : d.description,
          date: d.createdAt,
        ),
      ),
      ...payments.map(
        (p) => TimelineEntry(
          id: p.id,
          type: TimelineEntryType.payment,
          amount: p.amount,
          title: 'دفعة',
          subtitle: p.paymentMethod,
          date: p.createdAt,
        ),
      ),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return entries;
  }

  @override
  Stream<List<TimelineEntry>> watchTimeline(String customerId) {
    return (_db.select(_db.customers)..where((t) => t.id.equals(customerId)))
        .watch()
        .asyncMap((_) => getTimeline(customerId));
  }

  @override
  Future<Customer> updateCustomer(Customer customer) async {
    await (_db.update(_db.customers)..where((t) => t.id.equals(customer.id)))
        .write(
      CustomersCompanion(
        name: Value(customer.name),
        phone: Value(customer.phone),
        notes: Value(customer.notes),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return (await getById(customer.id))!;
  }

  @override
  Stream<List<CustomerListItem>> watchCustomers({
    String? query,
    CustomerDebtStatus? filter,
  }) {
    return _db.select(_db.customers).watch().asyncMap((rows) async {
      // Also trigger on payment changes by reading payments once
      await _db.select(_db.payments).get();
      await _db.select(_db.debts).get();

      final items = <CustomerListItem>[];
      final sorted = [...rows]
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      for (final row in sorted) {
        final customer = _map(row);
        if (query != null && query.trim().isNotEmpty) {
          final needle = query.trim().toLowerCase();
          final nameMatch = customer.name.toLowerCase().contains(needle);
          final phoneMatch =
              customer.phone?.toLowerCase().contains(needle) ?? false;
          if (!nameMatch && !phoneMatch) continue;
        }

        final balance = await getBalance(customer.id);
        final overdue = await _hasOverdue(customer.id, balance);
        final lastActivity = await _lastActivity(customer.id);

        final item = CustomerListItem(
          customer: customer,
          balance: balance,
          lastActivityAt: lastActivity,
          hasOverdueDebt: overdue,
        );

        if (filter != null && item.status != filter) continue;
        items.add(item);
      }
      return items;
    });
  }

  Future<bool> _hasOverdue(String customerId, CustomerBalance balance) async {
    if (!balance.hasDebt) return false;
    final debts = await (_db.select(_db.debts)
          ..where((t) => t.customerId.equals(customerId)))
        .get();
    return debts.any((d) => DateFormatter.isOverdue(d.dueDate));
  }

  Future<DateTime?> _lastActivity(String customerId) async {
    final debts = await (_db.select(_db.debts)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .get();
    final payments = await (_db.select(_db.payments)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .get();
    final dates = <DateTime>[
      if (debts.isNotEmpty) debts.first.createdAt,
      if (payments.isNotEmpty) payments.first.createdAt,
    ];
    if (dates.isEmpty) return null;
    dates.sort((a, b) => b.compareTo(a));
    return dates.first;
  }
}
