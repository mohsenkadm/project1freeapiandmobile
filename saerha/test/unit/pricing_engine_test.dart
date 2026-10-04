import 'package:flutter_test/flutter_test.dart';
import 'package:saerha/core/errors/app_exception.dart';
import 'package:saerha/features/calculator/domain/entities/cost_item.dart';
import 'package:saerha/features/calculator/domain/usecases/build_smart_insight.dart';
import 'package:saerha/features/calculator/domain/usecases/calculate_pricing.dart';
import 'package:saerha/features/settings/domain/entities/app_settings.dart';

void main() {
  const engine = CalculatePricing();
  const insights = BuildSmartInsight();

  group('CalculatePricing margin mode', () {
    test('purchase price must be > 0', () {
      expect(
        () => engine(purchasePrice: 0, targetPercent: 20),
        throwsA(isA<ValidationException>()),
      );
    });

    test('rejects negative purchase price', () {
      expect(
        () => engine(purchasePrice: -10, targetPercent: 20),
        throwsA(isA<ValidationException>()),
      );
    });

    test('rejects negative additional costs', () {
      expect(
        () => engine(
          purchasePrice: 1000,
          targetPercent: 20,
          costItems: const [
            CostItem(id: '1', name: 'نقل', amount: -5),
          ],
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('rejects margin 100%', () {
      expect(
        () => engine(purchasePrice: 1000, targetPercent: 100),
        throwsA(isA<ValidationException>()),
      );
    });

    test('rejects margin above 90%', () {
      expect(
        () => engine(purchasePrice: 1000, targetPercent: 95),
        throwsA(isA<ValidationException>()),
      );
    });

    test('additional costs = 0 and margin 0%', () {
      final result = engine(purchasePrice: 10000, targetPercent: 0);
      expect(result.totalCost, 10000);
      expect(result.suggestedPrice, 10000);
      expect(result.profit, 0);
    });

    test('margin 10%', () {
      final result = engine(purchasePrice: 9000, targetPercent: 10);
      expect(result.suggestedPrice, 10000);
      expect(result.profit, 1000);
      expect(result.profitMarginPercent, closeTo(10, 0.01));
    });

    test('margin 20% with costs — classic example', () {
      final result = engine(
        purchasePrice: 10000,
        targetPercent: 20,
        costItems: const [
          CostItem(id: '1', name: 'نقل', amount: 300),
          CostItem(id: '2', name: 'تغليف', amount: 200),
        ],
      );
      expect(result.totalCost, 10500);
      expect(result.suggestedPrice, 13125);
      expect(result.profit, 2625);
      expect(result.profitMarginPercent, closeTo(20, 0.01));
    });

    test('margin 50%', () {
      final result = engine(purchasePrice: 5000, targetPercent: 50);
      expect(result.suggestedPrice, 10000);
      expect(result.profit, 5000);
    });

    test('high values', () {
      final result = engine(purchasePrice: 2500000, targetPercent: 20);
      expect(result.suggestedPrice, 3125000);
      expect(result.profit, 625000);
    });

    test('decimal values round consistently', () {
      final result = engine(purchasePrice: 99.99, targetPercent: 20);
      expect(result.totalCost, 99.99);
      expect(result.suggestedPrice, closeTo(124.99, 0.01));
    });

    test('multiple costs sum correctly', () {
      final result = engine(
        purchasePrice: 1000,
        targetPercent: 20,
        costItems: const [
          CostItem(id: '1', name: 'أ', amount: 100),
          CostItem(id: '2', name: 'ب', amount: 50.5),
          CostItem(id: '3', name: 'ج', amount: 49.5),
        ],
      );
      expect(result.totalAdditionalCosts, 200);
      expect(result.totalCost, 1200);
      expect(result.suggestedPrice, 1500);
    });

    test('scenarios update around suggested price', () {
      final result = engine(purchasePrice: 10000, targetPercent: 20);
      expect(result.lowScenarioPrice, lessThan(result.suggestedPrice));
      expect(result.highScenarioPrice, greaterThan(result.suggestedPrice));
    });
  });

  group('CalculatePricing markup mode', () {
    test('20% markup on cost', () {
      final result = engine(
        purchasePrice: 10000,
        targetPercent: 20,
        marginMode: MarginMode.costMarkup,
        costItems: const [
          CostItem(id: '1', name: 'نقل', amount: 500),
        ],
      );
      expect(result.totalCost, 10500);
      expect(result.suggestedPrice, 12600);
      expect(result.profit, 2100);
    });
  });

  group('BuildSmartInsight', () {
    test('low margin message', () {
      final result = engine(purchasePrice: 10000, targetPercent: 5);
      final message = insights(result);
      expect(message, contains('منخفض'));
    });

    test('excellent margin message', () {
      final result = engine(purchasePrice: 10000, targetPercent: 45);
      final message = insights(result);
      expect(message, contains('ممتاز'));
    });
  });
}
