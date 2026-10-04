import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/customers/data/repositories/hive_customer_repository.dart';
import '../../features/customers/domain/entities/customer.dart';
import '../../features/customers/domain/repositories/customer_repository.dart';
import '../../features/orders/data/repositories/hive_order_repository.dart';
import '../../features/orders/domain/entities/order.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/domain/usecases/calculate_order_totals.dart';
import '../../features/orders/domain/usecases/change_order_status.dart';
import '../../features/orders/domain/usecases/compute_insights.dart';
import '../../features/orders/domain/usecases/create_order.dart';
import '../../features/orders/domain/usecases/filter_orders.dart';
import '../../features/products/data/repositories/hive_product_repository.dart';
import '../../features/products/domain/entities/product.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/settings/data/repositories/hive_settings_repository.dart';
import '../../features/settings/domain/entities/app_settings.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../services/notification_service.dart';
import '../storage/hive_storage.dart';

final hiveStorageProvider = Provider<HiveStorage>((ref) {
  throw UnimplementedError('HiveStorage must be overridden in main');
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError('NotificationService must be overridden in main');
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return HiveOrderRepository(ref.watch(hiveStorageProvider));
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return HiveCustomerRepository(ref.watch(hiveStorageProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return HiveProductRepository(ref.watch(hiveStorageProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return HiveSettingsRepository(ref.watch(hiveStorageProvider));
});

final calculateOrderTotalsProvider =
    Provider((ref) => const CalculateOrderTotals());

final filterOrdersProvider = Provider((ref) => const FilterOrders());

final computeCustomerTotalsProvider =
    Provider((ref) => const ComputeCustomerTotals());

final computeProductOrderCountsProvider =
    Provider((ref) => const ComputeProductOrderCounts());

final createOrderProvider = Provider((ref) {
  return CreateOrder(ref.watch(orderRepositoryProvider));
});

final changeOrderStatusProvider = Provider((ref) {
  return ChangeOrderStatus(ref.watch(orderRepositoryProvider));
});

final settingsProvider = StreamProvider<AppSettings>((ref) async* {
  final repo = ref.watch(settingsRepositoryProvider);
  yield await repo.get();
  // Poll lightly via settings box changes if available.
  final storage = ref.watch(hiveStorageProvider);
  yield* storage.settings.watch().asyncMap((_) => repo.get());
});

final ordersProvider = StreamProvider<List<Order>>((ref) {
  return ref.watch(orderRepositoryProvider).watchAll();
});

final customersProvider = StreamProvider<List<Customer>>((ref) {
  return ref.watch(customerRepositoryProvider).watchAll();
});

final productsProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).watchAll();
});

final orderByIdProvider =
    Provider.family<AsyncValue<Order?>, String>((ref, id) {
  final orders = ref.watch(ordersProvider);
  return orders.whenData(
    (list) {
      try {
        return list.firstWhere((o) => o.id == id);
      } catch (_) {
        return null;
      }
    },
  );
});

final customerByIdProvider =
    Provider.family<AsyncValue<Customer?>, String>((ref, id) {
  final customers = ref.watch(customersProvider);
  return customers.whenData(
    (list) {
      try {
        return list.firstWhere((c) => c.id == id);
      } catch (_) {
        return null;
      }
    },
  );
});

Future<void> refreshNotifications(WidgetRef ref) async {
  try {
    final settings = await ref.read(settingsRepositoryProvider).get();
    final orders = await ref.read(orderRepositoryProvider).getAll();
    final processing = orders
        .where((o) =>
            o.status.storageValue == 'new' ||
            o.status.storageValue == 'processing')
        .length;
    final delivery = orders
        .where((o) => o.status.storageValue == 'outForDelivery')
        .length;
    await ref.read(notificationServiceProvider).scheduleOrderReminder(
          enabled: settings.notificationsEnabled,
          pendingProcessing: processing,
          pendingDelivery: delivery,
        );
  } catch (e, st) {
    debugPrint('refreshNotifications failed: $e\n$st');
  }
}
