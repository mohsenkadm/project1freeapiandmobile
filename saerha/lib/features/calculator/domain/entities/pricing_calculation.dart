import 'package:equatable/equatable.dart';

import '../../../settings/domain/entities/app_settings.dart';
import 'cost_item.dart';

class PricingCalculation extends Equatable {
  const PricingCalculation({
    required this.id,
    this.productName,
    required this.purchasePrice,
    this.costItems = const [],
    required this.totalCost,
    required this.targetPercent,
    this.marginMode = MarginMode.sellingMargin,
    required this.suggestedPrice,
    required this.profit,
    required this.createdAt,
  });

  final String id;
  final String? productName;
  final double purchasePrice;
  final List<CostItem> costItems;
  final double totalCost;
  final double targetPercent;
  final MarginMode marginMode;
  final double suggestedPrice;
  final double profit;
  final DateTime createdAt;

  factory PricingCalculation.fromJson(Map<String, dynamic> json) {
    return PricingCalculation(
      id: json['id'] as String,
      productName: json['productName'] as String?,
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      costItems: (json['costItems'] as List<dynamic>? ?? const [])
          .map((e) => CostItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      totalCost: (json['totalCost'] as num).toDouble(),
      targetPercent: (json['targetPercent'] as num).toDouble(),
      marginMode: MarginMode.values.firstWhere(
        (e) => e.name == json['marginMode'],
        orElse: () => MarginMode.sellingMargin,
      ),
      suggestedPrice: (json['suggestedPrice'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productName': productName,
        'purchasePrice': purchasePrice,
        'costItems': costItems.map((e) => e.toJson()).toList(),
        'totalCost': totalCost,
        'targetPercent': targetPercent,
        'marginMode': marginMode.name,
        'suggestedPrice': suggestedPrice,
        'profit': profit,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        productName,
        purchasePrice,
        costItems,
        totalCost,
        targetPercent,
        marginMode,
        suggestedPrice,
        profit,
        createdAt,
      ];
}
