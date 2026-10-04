import '../entities/pricing_result.dart';

/// Dynamic Arabic insight messages based on pricing outcome.
class BuildSmartInsight {
  const BuildSmartInsight();

  String call(PricingResult result) {
    final messages = <String>[];

    final margin = result.profitMarginPercent;
    if (margin < 10) {
      messages.add('هامش الربح منخفض، تأكد أن السعر يغطي مصاريفك.');
    } else if (margin < 20) {
      messages.add('هامش مقبول، راقب المصاريف جيداً.');
    } else if (margin < 35) {
      messages.add('سعر جيد 👍');
    } else {
      messages.add('هامش ربح ممتاز 🔥');
    }

    if (result.totalAdditionalCosts > 0 &&
        result.totalAdditionalCosts >= result.purchasePrice * 0.15) {
      messages.add('المصاريف الإضافية رفعت تكلفة المنتج.');
    }

    if (result.lowScenarioProfit <= 0) {
      messages.add('السعر المنخفض قد يمحو ربحك — انتبه.');
    }

    return messages.join(' ');
  }
}
