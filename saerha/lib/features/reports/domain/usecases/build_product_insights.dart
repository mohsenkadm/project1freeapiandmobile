import 'package:equatable/equatable.dart';

import '../../../products/domain/entities/product.dart';

class ProductInsights extends Equatable {
  const ProductInsights({
    required this.count,
    required this.averageMarginPercent,
    this.highestProfit,
    this.lowestProfit,
  });

  final int count;
  final double averageMarginPercent;
  final Product? highestProfit;
  final Product? lowestProfit;

  @override
  List<Object?> get props =>
      [count, averageMarginPercent, highestProfit, lowestProfit];
}

class BuildProductInsights {
  const BuildProductInsights();

  ProductInsights call(List<Product> products) {
    if (products.isEmpty) {
      return const ProductInsights(count: 0, averageMarginPercent: 0);
    }

    double marginSum = 0;
    var highest = products.first;
    var lowest = products.first;

    for (final p in products) {
      final margin =
          p.suggestedPrice <= 0 ? 0.0 : (p.profit / p.suggestedPrice) * 100;
      marginSum += margin;
      if (p.profit > highest.profit) highest = p;
      if (p.profit < lowest.profit) lowest = p;
    }

    return ProductInsights(
      count: products.length,
      averageMarginPercent:
          double.parse((marginSum / products.length).toStringAsFixed(2)),
      highestProfit: highest,
      lowestProfit: lowest,
    );
  }
}
