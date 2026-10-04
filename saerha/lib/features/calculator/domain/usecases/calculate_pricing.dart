import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../entities/cost_item.dart';
import '../entities/pricing_result.dart';

/// Pure pricing engine — no Flutter/UI dependencies.
class CalculatePricing {
  const CalculatePricing();

  PricingResult call({
    required double purchasePrice,
    List<CostItem> costItems = const [],
    required double targetPercent,
    MarginMode marginMode = MarginMode.sellingMargin,
  }) {
    Validators.requirePositiveAmount(purchasePrice, field: 'سعر الشراء');
    for (final item in costItems) {
      Validators.requireNonNegative(item.amount, field: item.name);
    }
    Validators.requireValidMarginPercent(targetPercent);

    final totalAdditional =
        costItems.fold<double>(0, (sum, item) => sum + item.amount);
    final totalCost = _roundMoney(purchasePrice + totalAdditional);
    final ratio = targetPercent / 100;

    final suggested = switch (marginMode) {
      MarginMode.sellingMargin => _sellingPriceFromMargin(totalCost, ratio),
      MarginMode.costMarkup => _sellingPriceFromMarkup(totalCost, ratio),
    };

    final profit = _roundMoney(suggested - totalCost);
    final actualMargin = suggested <= 0 ? 0.0 : (profit / suggested) * 100;

    final low = _roundMoney(suggested * 0.91);
    final high = _roundMoney(suggested * 1.11);

    return PricingResult(
      purchasePrice: _roundMoney(purchasePrice),
      costItems: List.unmodifiable(costItems),
      totalAdditionalCosts: _roundMoney(totalAdditional),
      totalCost: totalCost,
      targetPercent: targetPercent,
      marginMode: marginMode,
      suggestedPrice: suggested,
      profit: profit,
      profitMarginPercent: _roundMoney(actualMargin),
      lowScenarioPrice: low,
      highScenarioPrice: high,
      lowScenarioProfit: _roundMoney(low - totalCost),
      highScenarioProfit: _roundMoney(high - totalCost),
    );
  }

  double _sellingPriceFromMargin(double cost, double margin) {
    if (margin >= 1) {
      throw const PricingException('لا يمكن حساب السعر بهذه النسبة.');
    }
    if (margin == 0) return _roundMoney(cost);
    return _roundMoney(cost / (1 - margin));
  }

  double _sellingPriceFromMarkup(double cost, double markup) {
    return _roundMoney(cost * (1 + markup));
  }

  double _roundMoney(double value) => (value * 100).roundToDouble() / 100;
}
