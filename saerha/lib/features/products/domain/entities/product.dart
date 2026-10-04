import 'package:equatable/equatable.dart';

import '../../../calculator/domain/entities/cost_item.dart';
import '../../../settings/domain/entities/app_settings.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.purchasePrice,
    this.additionalCosts = const [],
    required this.targetMargin,
    this.marginMode = MarginMode.sellingMargin,
    required this.suggestedPrice,
    required this.profit,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final double purchasePrice;
  final List<CostItem> additionalCosts;
  final double targetMargin;
  final MarginMode marginMode;
  final double suggestedPrice;
  final double profit;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product copyWith({
    String? id,
    String? name,
    double? purchasePrice,
    List<CostItem>? additionalCosts,
    double? targetMargin,
    MarginMode? marginMode,
    double? suggestedPrice,
    double? profit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      additionalCosts: additionalCosts ?? this.additionalCosts,
      targetMargin: targetMargin ?? this.targetMargin,
      marginMode: marginMode ?? this.marginMode,
      suggestedPrice: suggestedPrice ?? this.suggestedPrice,
      profit: profit ?? this.profit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      additionalCosts: (json['additionalCosts'] as List<dynamic>? ?? const [])
          .map((e) => CostItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      targetMargin: (json['targetMargin'] as num).toDouble(),
      marginMode: MarginMode.values.firstWhere(
        (e) => e.name == json['marginMode'],
        orElse: () => MarginMode.sellingMargin,
      ),
      suggestedPrice: (json['suggestedPrice'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'purchasePrice': purchasePrice,
        'additionalCosts': additionalCosts.map((e) => e.toJson()).toList(),
        'targetMargin': targetMargin,
        'marginMode': marginMode.name,
        'suggestedPrice': suggestedPrice,
        'profit': profit,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        name,
        purchasePrice,
        additionalCosts,
        targetMargin,
        marginMode,
        suggestedPrice,
        profit,
        createdAt,
        updatedAt,
      ];
}
