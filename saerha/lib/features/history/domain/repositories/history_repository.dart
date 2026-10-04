import '../../../calculator/domain/entities/pricing_calculation.dart';

abstract class HistoryRepository {
  Future<List<PricingCalculation>> getAll();
  Stream<List<PricingCalculation>> watchAll();
  Future<void> add(PricingCalculation calculation);
  Future<void> delete(String id);
  Future<void> clear();
}
