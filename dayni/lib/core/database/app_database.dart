import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('CustomerRow')
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DebtRow')
class Debts extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text().references(Customers, #id)();
  IntColumn get amount => integer()();
  TextColumn get description => text().withDefault(const Constant(''))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PaymentRow')
class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text().references(Customers, #id)();
  TextColumn get debtId => text().nullable()();
  IntColumn get amount => integer()();
  TextColumn get paymentMethod => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AppSettingsRow')
class AppSettingsRows extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  TextColumn get currency => text().withDefault(const Constant('IQD'))();
  TextColumn get localeCode => text().withDefault(const Constant('ar'))();
  BoolColumn get remindersEnabled =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get onboardingDone =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get dismissedQaidBanner =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AdConfigRow')
class AdConfigurations extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get ctaLabel => text()();
  TextColumn get ctaUrl => text().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Customers,
    Debts,
    Payments,
    AppSettingsRows,
    AdConfigurations,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await into(appSettingsRows).insert(
            AppSettingsRowsCompanion.insert(),
          );
          await into(adConfigurations).insert(
            AdConfigurationsCompanion.insert(
              id: 'qaid_home_banner',
              title: 'تدير محلّك بشكل أكبر؟ 🚀',
              body:
                  'مع قيد تقدر تدير المبيعات والمشتريات والمخزون والديون والتقارير.',
              ctaLabel: 'اكتشف قيد',
              ctaUrl: const Value('https://qaid.app'),
            ),
          );
        },
      );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'dayni.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }

  static AppDatabase memory() {
    return AppDatabase(NativeDatabase.memory());
  }
}
