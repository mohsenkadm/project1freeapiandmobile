# دَيني (Dayni)

تطبيق Flutter مجاني لإدارة ديون الزبائن لأصحاب المحلات والأعمال الصغيرة في العراق.

## المميزات

- Splash Screen متحرك مع هوية بصرية
- عربي بالكامل مع RTL
- Offline-first (Drift / SQLite)
- إدارة الزبائن والديون والدفعات
- لوحة ملخص بسيطة وتقارير خفيفة
- مشاركة كشف الحساب عبر Share Sheet
- Dark Mode
- بيانات تجريبية بعد Onboarding
- إعلان أنيق لنظام «قيد المحاسبي» عبر `AdService`

## التشغيل

```bash
flutter pub get
dart run build_runner build
flutter run
```

## الاختبارات

```bash
flutter analyze
flutter test
```

## البنية

Clean Architecture + Feature-first + Riverpod:

- `lib/core` — theme, database, routing, DI, splash helpers
- `lib/features/*` — splash, onboarding, customers, debts, payments, dashboard, reports, ads, settings
- الرصيد دائماً محسوب: `SUM(debts) - SUM(payments)`

## المنصات

جاهز للتطوير والنشر على Google Play و App Store.
