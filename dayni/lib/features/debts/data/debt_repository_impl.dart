import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/entities/debt.dart';
import '../domain/repositories/debt_repository.dart';

class DebtRepositoryImpl implements DebtRepository {
  DebtRepositoryImpl(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  Debt _map(DebtRow row) => Debt(
        id: row.id,
        customerId: row.customerId,
        amount: row.amount,
        description: row.description,
        dueDate: row.dueDate,
        notes: row.notes,
        createdAt: row.createdAt,
      );

  @override
  Future<Debt> addDebt({
    required String customerId,
    required int amount,
    required String description,
    DateTime? dueDate,
    String? notes,
    DateTime? createdAt,
  }) async {
    final id = _uuid.v4();
    final now = createdAt ?? DateTime.now();
    await _db.into(_db.debts).insert(
          DebtsCompanion.insert(
            id: id,
            customerId: customerId,
            amount: amount,
            description: Value(description),
            dueDate: Value(dueDate),
            notes: Value(notes),
            createdAt: now,
          ),
        );
    await (_db.update(_db.customers)..where((t) => t.id.equals(customerId)))
        .write(CustomersCompanion(updatedAt: Value(DateTime.now())));
    return (await getById(id))!;
  }

  @override
  Future<void> deleteDebt(String id) async {
    await (_db.delete(_db.debts)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<Debt>> getByCustomer(String customerId) async {
    final rows = await (_db.select(_db.debts)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(_map).toList();
  }

  @override
  Future<Debt?> getById(String id) async {
    final row = await (_db.select(_db.debts)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _map(row);
  }

  @override
  Stream<List<Debt>> watchRecent({int limit = 10}) {
    return (_db.select(_db.debts)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .watch()
        .map((rows) => rows.map(_map).toList());
  }
}
