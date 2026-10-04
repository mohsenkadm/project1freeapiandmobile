// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'دَيني';

  @override
  String get welcomeGreeting => 'أهلاً بك 👋';

  @override
  String get totalDebts => 'إجمالي الديون';

  @override
  String get customers => 'الزبائن';

  @override
  String get customersWithDebt => 'عليهم ديون';

  @override
  String get todaysPayments => 'دفعات اليوم';

  @override
  String get recentDebts => 'آخر الديون';

  @override
  String get addDebt => 'إضافة دين';

  @override
  String get addCustomer => 'إضافة زبون';

  @override
  String get saveCustomer => 'حفظ الزبون';

  @override
  String get customerName => 'اسم الزبون';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get notes => 'ملاحظات';

  @override
  String get required => 'مطلوب';

  @override
  String get home => 'الرئيسية';

  @override
  String get reports => 'التقارير';

  @override
  String get settings => 'الإعدادات';

  @override
  String get add => 'إضافة';

  @override
  String get recordPayment => 'تسجيل دفعة';

  @override
  String get saveDebt => 'حفظ الدين';

  @override
  String get amount => 'المبلغ';

  @override
  String get debtDescription => 'وصف الدين';

  @override
  String get debtDate => 'تاريخ الدين';

  @override
  String get dueDate => 'تاريخ الاستحقاق';

  @override
  String get optional => 'اختياري';

  @override
  String get selectCustomer => 'اختيار الزبون';

  @override
  String get debtSavedSuccess => 'تم تسجيل الدين بنجاح';

  @override
  String get customerSavedSuccess => 'تم حفظ الزبون بنجاح';

  @override
  String get paymentSavedSuccess => 'تم تسجيل الدفعة بنجاح';

  @override
  String get totalDebt => 'إجمالي الدين';

  @override
  String get paid => 'المدفوع';

  @override
  String get remaining => 'المتبقي';

  @override
  String get sendStatement => 'إرسال كشف';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get cash => 'نقدي';

  @override
  String get transfer => 'تحويل';

  @override
  String get other => 'أخرى';

  @override
  String get savePayment => 'تسجيل الدفعة';

  @override
  String get searchHint => 'ابحث بالاسم أو رقم الهاتف';

  @override
  String get customerCount => 'عدد الزبائن';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterWithDebt => 'لهم ديون';

  @override
  String get filterSettled => 'تم التسديد';

  @override
  String get filterOverdue => 'متأخر';

  @override
  String get filterNoDebt => 'بدون دين';

  @override
  String get statusHasDebt => 'له دين';

  @override
  String get statusSettled => 'تم التسديد';

  @override
  String get statusOverdue => 'متأخر';

  @override
  String get statusNoDebt => 'بدون دين';

  @override
  String get dueToday => 'مستحق اليوم';

  @override
  String get overdue => 'متأخر';

  @override
  String daysRemaining(int days) {
    return 'متبقي $days يوم';
  }

  @override
  String daysAgo(int days) {
    return 'منذ $days أيام';
  }

  @override
  String get dayAgo => 'منذ يوم';

  @override
  String get today => 'اليوم';

  @override
  String get newDebt => 'دين جديد';

  @override
  String get payment => 'دفعة';

  @override
  String get emptyCustomersTitle => 'ما عندك زبائن بعد';

  @override
  String get emptyCustomersSubtitle => 'أضف أول زبون وابدأ بتنظيم ديونك.';

  @override
  String get emptyDebtsTitle => 'ما عندك ديون مسجلة 🎉';

  @override
  String get emptyDebtsSubtitle => 'سجّل أول دين وابدأ المتابعة.';

  @override
  String get onboardingTitle1 => 'لا تنسى ديون زبائنك';

  @override
  String get onboardingSubtitle1 => 'احتفظ بسجل واضح لكل زبون ومبالغه.';

  @override
  String get onboardingTitle2 => 'سجل الدين والدفعات بسهولة';

  @override
  String get onboardingSubtitle2 => 'أضف دين أو دفعة خلال ثوانٍ فقط.';

  @override
  String get onboardingTitle3 => 'وتابع المبلغ المتبقي في أي وقت';

  @override
  String get onboardingSubtitle3 => 'ملخص سريع وكشف حساب جاهز للمشاركة.';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get currency => 'العملة';

  @override
  String get language => 'اللغة';

  @override
  String get reminderNotifications => 'إشعارات التذكير';

  @override
  String get appVersion => 'نسخة التطبيق';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsOfUse => 'شروط الاستخدام';

  @override
  String get backupComingSoon => 'النسخ الاحتياطي قريباً';

  @override
  String get loadDemoData => 'تحميل بيانات تجريبية';

  @override
  String get demoDataLoaded => 'تم تحميل البيانات التجريبية';

  @override
  String get arabic => 'العربية';

  @override
  String get currencyIqd => 'د.ع';

  @override
  String get totalPayments => 'إجمالي الدفعات';

  @override
  String get debtorCustomers => 'العملاء المدينون';

  @override
  String get overdueDebts => 'الديون المتأخرة';

  @override
  String get topDebtors => 'أفضل 5 زبائن من حيث الدين';

  @override
  String get qaidBannerTitle => 'تدير محلّك بشكل أكبر؟ 🚀';

  @override
  String get qaidBannerBody =>
      'مع قيد تقدر تدير المبيعات والمشتريات والمخزون والديون والتقارير.';

  @override
  String get discoverQaid => 'اكتشف قيد';

  @override
  String get qaidPageTitle => 'كبر شغلك مع قيد';

  @override
  String get tryQaidFree => 'جرّب قيد مجاناً';

  @override
  String get qaidFeatureSales => 'المبيعات';

  @override
  String get qaidFeaturePurchases => 'المشتريات';

  @override
  String get qaidFeatureInventory => 'المخازن';

  @override
  String get qaidFeatureDebts => 'الديون';

  @override
  String get qaidFeatureInstallments => 'الأقساط';

  @override
  String get qaidFeatureReports => 'التقارير';

  @override
  String get qaidFeatureBarcode => 'الباركود';

  @override
  String get qaidFeatureMobile => 'تطبيق الموبايل';

  @override
  String get qaidFeatureBranches => 'الفروع';

  @override
  String get errorAmountRequired => 'المبلغ مطلوب';

  @override
  String get errorAmountPositive => 'المبلغ يجب أن يكون أكبر من صفر';

  @override
  String get errorAmountExceedsBalance => 'الدفعة أكبر من الدين المتبقي';

  @override
  String get errorNameRequired => 'اسم الزبون مطلوب';

  @override
  String get errorCustomerRequired => 'يجب اختيار زبون';

  @override
  String get errorGeneric => 'حدث خطأ، حاول مرة أخرى';

  @override
  String get lastActivity => 'آخر حركة';

  @override
  String get statementTitle => 'كشف حساب الزبون';

  @override
  String get statementName => 'الاسم';

  @override
  String get statementTotalDebt => 'إجمالي الدين';

  @override
  String get statementPaid => 'المدفوع';

  @override
  String get statementRemaining => 'المتبقي';

  @override
  String get statementLastPayment => 'آخر دفعة';

  @override
  String get statementThanks => 'شكراً لتعاملك معنا.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get close => 'إغلاق';

  @override
  String get dismiss => 'إخفاء';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get privacyContent =>
      'بياناتك محلية على جهازك. لا نرسل بيانات الزبائن إلى أي خادم بدون موافقتك. لا نجمع بيانات شخصية غير ضرورية.';

  @override
  String get termsContent =>
      'دَيني تطبيق مجاني لإدارة ديون الزبائن. استخدمه على مسؤوليتك. نحن غير مسؤولين عن فقدان البيانات قبل تفعيل النسخ الاحتياطي.';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get descriptionHint => 'مثلاً: شراء بضاعة';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get none => 'لا يوجد';

  @override
  String get iqdSuffix => 'د.ع';
}
