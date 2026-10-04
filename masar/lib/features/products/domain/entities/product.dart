import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.sellingPrice,
    required this.createdAt,
    required this.updatedAt,
    this.costPrice,
  });

  final String id;
  final String name;
  final double sellingPrice;
  final double? costPrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product copyWith({
    String? id,
    String? name,
    double? sellingPrice,
    double? costPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearCost = false,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      costPrice: clearCost ? null : (costPrice ?? this.costPrice),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sellingPrice': sellingPrice,
        'costPrice': costPrice,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble() ?? 0,
      costPrice: (json['costPrice'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props =>
      [id, name, sellingPrice, costPrice, createdAt, updatedAt];
}
