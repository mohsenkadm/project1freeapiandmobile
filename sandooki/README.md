# صندوقي (Sandooki)

تطبيق Flutter مجاني Offline-first يساعد أصحاب المحلات على معرفة الفرق بين الرصيد المتوقع داخل الصندوق والرصيد الفعلي في نهاية اليوم.

**اعرف وين راحت فلوسك**

## المميزات

- عربي بالكامل مع RTL (لهجة عراقية بسيطة)
- Dark Mode كتصميم أساسي + Light Mode
- تسجيل حركات: مبيعات / مصروف / دفعة / سحب
- جرد نهاية اليوم مع حساب الفرق Animated
- تقرير يومي + سجل الأيام السابقة
- ترويج ذكي لنظام «قيد المحاسبي»
- تخزين محلي Hive (بدون Backend)
- إشعار تذكير اختياري للجرد مساءً

## البنية

Clean Architecture + Feature-first + Riverpod:

```
lib/
  core/           # theme, router, DI, storage, widgets
  features/
    splash/
    onboarding/
    dashboard/
    transactions/
    cash_count/
    reports/
    settings/
    qayd_promotion/
```

منطق الرصيد (مستقل عن UI):

```
expected = openingBalance + sales - expenses - payments - withdrawals
difference = actualBalance - expectedBalance
```

## أهم الملفات

| ملف | الدور |
|-----|--------|
| `lib/main.dart` | تهيئة Hive والإشعارات |
| `lib/core/theme/` | Design System |
| `lib/core/di/providers.dart` | Dependency Injection |
| `lib/core/router/app_router.dart` | GoRouter |
| `lib/features/*/domain/` | Entities + Use Cases |
| `lib/features/*/data/` | Hive Repositories |

## Dependencies

- flutter_riverpod, go_router
- hive / hive_flutter
- freezed / json_serializable
- flutter_animate, google_fonts, fl_chart
- flutter_local_notifications, timezone
- intl, uuid, url_launcher, equatable

## التشغيل

```bash
cd sandooki
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## الاختبارات

```bash
flutter analyze
flutter test
```

الاختبارات الحالية (`test/unit/cash_balance_test.dart`):

- Zero transactions
- Sales only / Expenses only / Mixed
- Exact match / Shortage / Surplus
- Negative amount abs handling
- Large amounts
- BuildDailyCashSummary

## Build

### Android

```bash
flutter build apk
flutter build appbundle
```

Application ID: `com.qaid.sandooki`

### iOS

```bash
flutter build ipa
```

Display Name: صندوقي

## ملاحظات المنتج

- لا يجمع بيانات شخصية
- لا Analytics في النسخة الأولى
- كل البيانات محلية على الجهاز
- يمكن إضافة Backend لاحقاً عبر استبدال الـ Repositories فقط
