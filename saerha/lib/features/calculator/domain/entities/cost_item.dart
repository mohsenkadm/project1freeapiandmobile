import 'package:equatable/equatable.dart';

class CostItem extends Equatable {
  const CostItem({
    required this.id,
    required this.name,
    required this.amount,
  });

  final String id;
  final String name;
  final double amount;

  CostItem copyWith({
    String? id,
    String? name,
    double? amount,
  }) {
    return CostItem(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
    );
  }

  factory CostItem.fromJson(Map<String, dynamic> json) {
    return CostItem(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
      };

  @override
  List<Object?> get props => [id, name, amount];
}
