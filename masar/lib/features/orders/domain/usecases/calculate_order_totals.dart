import '../../../../core/errors/app_exception.dart';
import '../entities/order_item.dart';

class OrderTotals {
  const OrderTotals({
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
    required this.paidAmount,
    required this.remainingAmount,
    this.estimatedCost,
    this.estimatedProfit,
  });

  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;
  final double paidAmount;
  final double remainingAmount;
  final double? estimatedCost;
  final double? estimatedProfit;
}

class CalculateOrderTotals {
  const CalculateOrderTotals();

  OrderTotals call({
    required List<OrderItem> items,
    double discount = 0,
    double deliveryFee = 0,
    double paidAmount = 0,
    bool allowOverpay = false,
  }) {
    if (items.isEmpty) {
      throw const ValidationException(
        'تأكد من إضافة منتج واحد على الأقل.',
      );
    }
    for (final item in items) {
      if (item.quantity <= 0) {
        throw const ValidationException('الكمية يجب أن تكون أكبر من صفر.');
      }
      if (item.unitPrice < 0) {
        throw const ValidationException('السعر لا يمكن أن يكون سالباً.');
      }
      if (item.costPrice != null && item.costPrice! < 0) {
        throw const ValidationException('تكلفة المنتج لا يمكن أن تكون سالبة.');
      }
    }
    if (discount < 0) {
      throw const ValidationException('الخصم لا يمكن أن يكون سالباً.');
    }
    if (deliveryFee < 0) {
      throw const ValidationException('أجرة التوصيل لا يمكن أن تكون سالبة.');
    }
    if (paidAmount < 0) {
      throw const ValidationException(
        'المبلغ المدفوع لا يمكن أن يكون سالباً.',
      );
    }

    final subtotal =
        items.fold<double>(0, (sum, item) => sum + item.lineTotal);
    if (discount > subtotal) {
      throw const ValidationException(
        'الخصم لا يمكن أن يكون أكبر من قيمة المنتجات.',
      );
    }

    final total = subtotal - discount + deliveryFee;
    if (!allowOverpay && paidAmount > total) {
      throw const ValidationException(
        'المبلغ المدفوع لا يمكن أن يكون أكبر من الإجمالي.',
      );
    }

    final remaining = total - paidAmount;

    final allHaveCost = items.every((e) => e.costPrice != null);
    double? estimatedCost;
    double? estimatedProfit;
    if (allHaveCost && items.isNotEmpty) {
      estimatedCost =
          items.fold<double>(0, (sum, item) => sum + (item.lineCost ?? 0));
      estimatedProfit = total - estimatedCost - deliveryFee;
    }

    return OrderTotals(
      subtotal: subtotal,
      discount: discount,
      deliveryFee: deliveryFee,
      total: total,
      paidAmount: paidAmount,
      remainingAmount: remaining,
      estimatedCost: estimatedCost,
      estimatedProfit: estimatedProfit,
    );
  }
}
