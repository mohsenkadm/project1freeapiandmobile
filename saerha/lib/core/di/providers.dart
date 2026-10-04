import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/calculator/domain/entities/pricing_calculation.dart';
import '../../features/calculator/domain/usecases/build_smart_insight.dart';
import '../../features/calculator/domain/usecases/calculate_pricing.dart';
import '../../features/history/data/repositories/hive_history_repository.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/products/data/repositories/hive_product_repository.dart';
import '../../features/products/domain/entities/product.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/reports/domain/usecases/build_product_insights.dart';
import '../../features/settings/data/repositories/hive_settings_repository.dart';
import '../../features/settings/domain/entities/app_settings.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../services/notification_service.dart';
import '../services/share_result_service.dart';
import '../storage/hive_storage.dart';

final hiveStorageProvider = Provider<HiveStorage>((ref) {
  throw UnimplementedError('HiveStorage must be overridden in main');
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError('NotificationService must be overridden in main');
});

final shareResultServiceProvider = Provider<ShareResultService>((ref) {
  return const ShareResultService();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return HiveSettingsRepository(ref.watch(hiveStorageProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return HiveProductRepository(ref.watch(hiveStorageProvider));
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HiveHistoryRepository(ref.watch(hiveStorageProvider));
});

final calculatePricingProvider = Provider((ref) => const CalculatePricing());

final buildSmartInsightProvider = Provider((ref) => const BuildSmartInsight());

final buildProductInsightsProvider =
    Provider((ref) => const BuildProductInsights());

final settingsProvider = StreamProvider<AppSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).watch();
});

final productsProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).watchAll();
});

final historyProvider = StreamProvider<List<PricingCalculation>>((ref) {
  return ref.watch(historyRepositoryProvider).watchAll();
});

final productInsightsProvider = Provider((ref) {
  final products = ref.watch(productsProvider).asData?.value ?? const [];
  return ref.watch(buildProductInsightsProvider)(products);
});
