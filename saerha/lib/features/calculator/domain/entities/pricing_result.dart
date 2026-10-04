import 'package:equatable/equatable.dart';

import '../../../settings/domain/entities/app_settings.dart';
import 'cost_item.dart';

/// Immutable result of a pricing calculation.
class PricingResult extends Equatable {
  const PricingResult({
    required this.purchasePrice,
    required this.costItems,
    required this.totalAdditionalCosts,
    required this.totalCost,
    required this.targetPercent,
    required this.marginMode,
    required this.suggestedPrice,
    required this.profit,
    required this.profitMarginPercent,
    required this.lowScenarioPrice,
    required this.highScenarioPrice,
    required this.lowScenarioProfit,
    required this.highScenarioProfit,
  });

  final double purchasePrice;
  final List<CostItem> costItems;
  final double totalAdditionalCosts;
  final double totalCost;
  final double targetPercent;
  final MarginMode marginMode;
  final double suggestedPrice;
  final double profit;
  final double profitMarginPercent;
  final double lowScenarioPrice;
  final double highScenarioPrice;
  final double lowScenarioProfit;
  final double highScenarioProfit;

  @override
  List<Object?> get props => [
        purchasePrice,
        costItems,
        totalAdditionalCosts,
        totalCost,
        targetPercent,
        marginMode,
        suggestedPrice,
        profit,
        profitMarginPercent,
        lowScenarioPrice,
        highScenarioPrice,
        lowScenarioProfit,
        highScenarioProfit,
      ];
}
