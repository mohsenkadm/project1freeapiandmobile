import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/entities/payment.dart';
import '../domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  Payment _map(PaymentRow row) => Payment(
        id: row.id,
        customerId: row.customerId,
        debtId: row.debtId,
        amount: row.amount,
        paymentMethod: _parseMethod(row.paymentMethod),
        notes: row.notes,
        createdAt: row.createdAt,
      );

  PaymentMethod _parseMethod(String value) {
    return PaymentMethod.values.firstWhere(
      (m) => m.name == value,
      orElse: () => PaymentMethod.cash,
    );
  }

  @override
  Future<Payment> addPayment({
    required String customerId,
    required int amount,
    required PaymentMethod paymentMethod,
    String? debtId,
    String? notes,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _db.into(_db.payments).insert(
          PaymentsCompanion.insert(
            id: id,
            customerId: customerId,
            debtId: Value(debtId),
            amount: amount,
            paymentMethod: paymentMethod.name,
            notes: Value(notes),
            createdAt: now,
          ),
        );
    await (_db.update(_db.customers)..where((t) => t.id.equals(customerId)))
        .write(CustomersCompanion(updatedAt: Value(now)));

    final row = await (_db.select(_db.payments)..where((t) => t.id.equals(id)))
        .getSingle();
    return _map(row);
  }

  @override
  Future<void> deletePayment(String id) async {
    await (_db.delete(_db.payments)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<Payment>> getByCustomer(String customerId) async {
    final rows = await (_db.select(_db.payments)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(_map).toList();
  }

  @override
  Future<Payment?> getLastPayment(String customerId) async {
    final rows = await (_db.select(_db.payments)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .get();
    if (rows.isEmpty) return null;
    return _map(rows.first);
  }

  DateTime _startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  Future<int> todaysPaymentsAmount() async {
    final start = _startOfToday();
    final sum = _db.payments.amount.sum();
    final query = _db.selectOnly(_db.payments)
      ..addColumns([sum])
      ..where(_db.payments.createdAt.isBiggerOrEqualValue(start));
    final row = await query.getSingle();
    return row.read(sum) ?? 0;
  }

  @override
  Future<int> todaysPaymentsCount() async {
    final start = _startOfToday();
    final count = _db.payments.id.count();
    final query = _db.selectOnly(_db.payments)
      ..addColumns([count])
      ..where(_db.payments.createdAt.isBiggerOrEqualValue(start));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
