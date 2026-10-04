# مسار (Masar)

تطبيق Flutter Offline-first لإدارة دورة حياة الطلبات لأصحاب المحلات والمشاريع الصغيرة والمتوسطة في العراق.

**لا تخلي أي طلب يضيع.**

## المميزات

- عربي بالكامل مع RTL
- Dark Mode كتصميم أساسي + Light Mode اختياري
- إنشاء طلب خلال ثوانٍ (زبون → منتجات → دفع → ملاحظات)
- حالات الطلب: جديد / قيد التجهيز / جاهز / قيد التوصيل / تم التسليم / ملغي
- زبائن ومنتجات بسيطة (بدون CRM أو مخزون متقدم)
- شاشة توصيل + تقارير قيمة الطلبات
- مشاركة بطاقة الطلب وإرسال رسالة واتساب يدوياً
- ترويج ذكي لـ «قيد المحاسبي»
- تخزين محلي Hive (بدون Backend)
- إشعارات تذكير اختيارية

## البنية

Clean Architecture + Feature-first + Riverpod:

```
lib/
  core/           # theme, router, DI, storage, widgets
  features/
    splash/
    onboarding/
    dashboard/
    orders/
    customers/
    products/
    delivery/
    reports/
    settings/
    qayd_promotion/
```

منطق الإجماليات (مستقل عن UI):

```
subtotal = Σ(qty × unitPrice)
total = subtotal - discount + deliveryFee
remaining = total - paidAmount
estimatedCost = Σ(qty × costPrice)   # عند توفر التكلفة
estimatedProfit = total - estimatedCost - deliveryFee
```

## Dependencies

- flutter_riverpod, go_router
- hive / hive_flutter
- flutter_animate, google_fonts, fl_chart
- share_plus, url_launcher
- flutter_local_notifications, timezone
- intl, uuid, equatable

## التشغيل

```bash
cd masar
flutter pub get
dart run flutter_launcher_icons
flutter run
```

## الاختبارات

```bash
flutter analyze
flutter test
```

## البناء

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

- Android applicationId: `com.qaid.masar`
- iOS bundle id: `com.qaid.masar`

## ملاحظات المنتج

- مسار يدير الطلبات فقط — ليس نظام محاسبة أو POS أو ERP.
- الربح المعروض «ربح تقديري» فقط عند إدخال تكلفة المنتج.
- للصورة المحاسبية الكاملة: **مسار يدير طلباتك. قيد يدير تجارتك.**
- كل البيانات محلية في النسخة الأولى؛ واجهات المستودعات جاهزة لمزامنة سحابية مستقبلاً.
