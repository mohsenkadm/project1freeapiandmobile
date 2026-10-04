# سعّرها (Saerha)

تطبيق Flutter مجاني Offline-first يساعد أصحاب المحلات والمشاريع الصغيرة على حساب تكلفة المنتج الحقيقية وسعر البيع المقترح والربح وهامش الربح بسرعة.

**لا تسعّر على التخمين… سعّر على الربح.**

## المميزات

- عربي بالكامل مع RTL
- Dark Premium كتصميم أساسي + Light Mode
- حاسبة تسعير فورية (هامش من سعر البيع أو زيادة على التكلفة)
- مصاريف إضافية متعددة
- سيناريوهات أسعار + تفصيل تكلفة + رسائل ذكية
- حفظ المنتجات + بحث/تعديل/حذف/تكرار
- سجل آخر التسعيرات
- نظرة سريعة (Insights) بدون محاسبة
- مشاركة نتيجة التسعير كصورة
- ترويج ذكي لنظام «قيد المحاسبي»
- تخزين محلي Hive (بدون Backend)

## البنية

Clean Architecture + Feature-first + Riverpod:

```
lib/
  core/           # theme, router, DI, storage, widgets
  features/
    splash/
    onboarding/
    home/
    calculator/
    products/
    history/
    reports/
    settings/
    qayd_promotion/
```

منطق التسعير (مستقل عن UI):

```
totalCost = purchasePrice + sum(additionalCosts)
# هامش من سعر البيع:
suggestedPrice = totalCost / (1 - margin)
# أو زيادة على التكلفة:
suggestedPrice = totalCost * (1 + markup)
profit = suggestedPrice - totalCost
```

## Dependencies

- flutter_riverpod, go_router
- hive / hive_flutter
- equatable
- flutter_animate, google_fonts
- share_plus, url_launcher
- flutter_local_notifications, timezone
- intl, uuid, equatable

## التشغيل

```bash
cd saerha
flutter pub get
flutter run
```

## الاختبارات

```bash
flutter analyze
flutter test
```

الاختبارات الحالية:

- `test/unit/pricing_engine_test.dart` — محرك التسعير والتحقق
- `test/unit/money_formatter_test.dart` — تنسيق المبالغ
- `test/unit/product_insights_test.dart` — رؤى المنتجات

## Build

### Android

```bash
flutter build apk
flutter build appbundle
```

Application ID: `com.qaid.saerha`

### iOS

```bash
flutter build ipa
```

Bundle ID: `com.qaid.saerha`

## ملاحظات مهمة

- التطبيق أداة تسعير فقط — ليس نظام محاسبة.
- روابط قيد قابلة للضبط من `lib/core/constants/app_constants.dart`.
- كل البيانات محلية ولا تُرسل لأي خادم.
