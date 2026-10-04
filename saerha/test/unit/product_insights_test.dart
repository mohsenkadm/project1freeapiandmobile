import 'package:flutter_test/flutter_test.dart';
import 'package:saerha/features/products/domain/entities/product.dart';
import 'package:saerha/features/reports/domain/usecases/build_product_insights.dart';

void main() {
  const builder = BuildProductInsights();

  test('empty products', () {
    final insights = builder(const []);
    expect(insights.count, 0);
    expect(insights.averageMarginPercent, 0);
  });

  test('computes average and extremes', () {
    final now = DateTime(2026, 1, 1);
    final products = [
      Product(
        id: '1',
        name: 'A',
        purchasePrice: 1000,
        targetMargin: 20,
        suggestedPrice: 1250,
        profit: 250,
        createdAt: now,
        updatedAt: now,
      ),
      Product(
        id: '2',
        name: 'B',
        purchasePrice: 2000,
        targetMargin: 50,
        suggestedPrice: 4000,
        profit: 2000,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    final insights = builder(products);
    expect(insights.count, 2);
    expect(insights.highestProfit?.name, 'B');
    expect(insights.lowestProfit?.name, 'A');
    expect(insights.averageMarginPercent, greaterThan(0));
  });
}
