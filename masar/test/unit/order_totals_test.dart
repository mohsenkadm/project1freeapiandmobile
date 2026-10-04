import 'package:flutter_test/flutter_test.dart';
import 'package:masar/features/orders/domain/entities/order_item.dart';
import 'package:masar/features/orders/domain/usecases/calculate_order_totals.dart';
import 'package:masar/core/errors/app_exception.dart';

void main() {
  const calculator = CalculateOrderTotals();

  group('CalculateOrderTotals', () {
    test('computes subtotal discount delivery total remaining', () {
      final totals = calculator(
        items: const [
          OrderItem(
            productId: '1',
            productName: 'عطر',
            quantity: 2,
            unitPrice: 25000,
            costPrice: 15000,
          ),
          OrderItem(
            productId: '2',
            productName: 'كريم',
            quantity: 1,
            unitPrice: 25000,
            costPrice: 10000,
          ),
        ],
        discount: 5000,
        deliveryFee: 5000,
        paidAmount: 40000,
      );

      expect(totals.subtotal, 75000);
      expect(totals.total, 75000);
      expect(totals.remainingAmount, 35000);
      expect(totals.estimatedCost, 40000);
      expect(totals.estimatedProfit, 30000);
    });

    test('hides estimated profit when cost missing', () {
      final totals = calculator(
        items: const [
          OrderItem(
            productId: '1',
            productName: 'عطر',
            quantity: 1,
            unitPrice: 25000,
          ),
        ],
      );
      expect(totals.estimatedCost, isNull);
      expect(totals.estimatedProfit, isNull);
    });

    test('supports zero values', () {
      final totals = calculator(
        items: const [
          OrderItem(
            productId: '1',
            productName: 'هدية',
            quantity: 1,
            unitPrice: 0,
            costPrice: 0,
          ),
        ],
        discount: 0,
        deliveryFee: 0,
        paidAmount: 0,
      );
      expect(totals.total, 0);
      expect(totals.remainingAmount, 0);
      expect(totals.estimatedProfit, 0);
    });

    test('supports large numbers', () {
      final totals = calculator(
        items: const [
          OrderItem(
            productId: '1',
            productName: 'جملة',
            quantity: 100,
            unitPrice: 150000,
            costPrice: 100000,
          ),
        ],
        deliveryFee: 25000,
      );
      expect(totals.subtotal, 15000000);
      expect(totals.total, 15025000);
      expect(totals.estimatedProfit, 5000000);
    });

    test('rejects empty items', () {
      expect(
        () => calculator(items: const []),
        throwsA(isA<ValidationException>()),
      );
    });

    test('rejects paid greater than total', () {
      expect(
        () => calculator(
          items: const [
            OrderItem(
              productId: '1',
              productName: 'عطر',
              quantity: 1,
              unitPrice: 10000,
            ),
          ],
          paidAmount: 20000,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('rejects negative quantity and discount', () {
      expect(
        () => calculator(
          items: const [
            OrderItem(
              productId: '1',
              productName: 'عطر',
              quantity: 0,
              unitPrice: 10000,
            ),
          ],
        ),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => calculator(
          items: const [
            OrderItem(
              productId: '1',
              productName: 'عطر',
              quantity: 1,
              unitPrice: 10000,
            ),
          ],
          discount: -1,
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
