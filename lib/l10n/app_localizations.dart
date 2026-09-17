import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'دَيني'**
  String get appName;

  /// No description provided for @welcomeGreeting.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك 👋'**
  String get welcomeGreeting;

  /// No description provided for @totalDebts.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الديون'**
  String get totalDebts;

  /// No description provided for @customers.
  ///
  /// In ar, this message translates to:
  /// **'الزبائن'**
  String get customers;

  /// No description provided for @customersWithDebt.
  ///
  /// In ar, this message translates to:
  /// **'عليهم ديون'**
  String get customersWithDebt;

  /// No description provided for @todaysPayments.
  ///
  /// In ar, this message translates to:
  /// **'دفعات اليوم'**
  String get todaysPayments;

  /// No description provided for @recentDebts.
  ///
  /// In ar, this message translates to:
  /// **'آخر الديون'**
  String get recentDebts;

  /// No description provided for @addDebt.
  ///
  /// In ar, this message translates to:
  /// **'إضافة دين'**
  String get addDebt;

  /// No description provided for @addCustomer.
  ///
  /// In ar, this message translates to:
  /// **'إضافة زبون'**
  String get addCustomer;

  /// No description provided for @saveCustomer.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الزبون'**
  String get saveCustomer;

  /// No description provided for @customerName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الزبون'**
  String get customerName;

  /// No description provided for @phoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumber;

  /// No description provided for @notes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get notes;

  /// No description provided for @required.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب'**
  String get required;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @reports.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @add.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get add;

  /// No description provided for @recordPayment.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل دفعة'**
  String get recordPayment;

  /// No description provided for @saveDebt.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الدين'**
  String get saveDebt;

  /// No description provided for @amount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get amount;

  /// No description provided for @debtDescription.
  ///
  /// In ar, this message translates to:
  /// **'وصف الدين'**
  String get debtDescription;

  /// No description provided for @debtDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الدين'**
  String get debtDate;

  /// No description provided for @dueDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الاستحقاق'**
  String get dueDate;

  /// No description provided for @optional.
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get optional;

  /// No description provided for @selectCustomer.
  ///
  /// In ar, this message translates to:
  /// **'اختيار الزبون'**
  String get selectCustomer;

  /// No description provided for @debtSavedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الدين بنجاح'**
  String get debtSavedSuccess;

  /// No description provided for @customerSavedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الزبون بنجاح'**
  String get customerSavedSuccess;

  /// No description provided for @paymentSavedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الدفعة بنجاح'**
  String get paymentSavedSuccess;

  /// No description provided for @totalDebt.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الدين'**
  String get totalDebt;

  /// No description provided for @paid.
  ///
  /// In ar, this message translates to:
  /// **'المدفوع'**
  String get paid;

  /// No description provided for @remaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي'**
  String get remaining;

  /// No description provided for @sendStatement.
  ///
  /// In ar, this message translates to:
  /// **'إرسال كشف'**
  String get sendStatement;

  /// No description provided for @paymentMethod.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get paymentMethod;

  /// No description provided for @cash.
  ///
  /// In ar, this message translates to:
  /// **'نقدي'**
  String get cash;

  /// No description provided for @transfer.
  ///
  /// In ar, this message translates to:
  /// **'تحويل'**
  String get transfer;

  /// No description provided for @other.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get other;

  /// No description provided for @savePayment.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدفعة'**
  String get savePayment;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث بالاسم أو رقم الهاتف'**
  String get searchHint;

  /// No description provided for @customerCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد الزبائن'**
  String get customerCount;

  /// No description provided for @filterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get filterAll;

  /// No description provided for @filterWithDebt.
  ///
  /// In ar, this message translates to:
  /// **'لهم ديون'**
  String get filterWithDebt;

  /// No description provided for @filterSettled.
  ///
  /// In ar, this message translates to:
  /// **'تم التسديد'**
  String get filterSettled;

  /// No description provided for @filterOverdue.
  ///
  /// In ar, this message translates to:
  /// **'متأخر'**
  String get filterOverdue;

  /// No description provided for @filterNoDebt.
  ///
  /// In ar, this message translates to:
  /// **'بدون دين'**
  String get filterNoDebt;

  /// No description provided for @statusHasDebt.
  ///
  /// In ar, this message translates to:
  /// **'له دين'**
  String get statusHasDebt;

  /// No description provided for @statusSettled.
  ///
  /// In ar, this message translates to:
  /// **'تم التسديد'**
  String get statusSettled;

  /// No description provided for @statusOverdue.
  ///
  /// In ar, this message translates to:
  /// **'متأخر'**
  String get statusOverdue;

  /// No description provided for @statusNoDebt.
  ///
  /// In ar, this message translates to:
  /// **'بدون دين'**
  String get statusNoDebt;

  /// No description provided for @dueToday.
  ///
  /// In ar, this message translates to:
  /// **'مستحق اليوم'**
  String get dueToday;

  /// No description provided for @overdue.
  ///
  /// In ar, this message translates to:
  /// **'متأخر'**
  String get overdue;

  /// No description provided for @daysRemaining.
  ///
  /// In ar, this message translates to:
  /// **'متبقي {days} يوم'**
  String daysRemaining(int days);

  /// No description provided for @daysAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {days} أيام'**
  String daysAgo(int days);

  /// No description provided for @dayAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ يوم'**
  String get dayAgo;

  /// No description provided for @today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// No description provided for @newDebt.
  ///
  /// In ar, this message translates to:
  /// **'دين جديد'**
  String get newDebt;

  /// No description provided for @payment.
  ///
  /// In ar, this message translates to:
  /// **'دفعة'**
  String get payment;

  /// No description provided for @emptyCustomersTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك زبائن بعد'**
  String get emptyCustomersTitle;

  /// No description provided for @emptyCustomersSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أضف أول زبون وابدأ بتنظيم ديونك.'**
  String get emptyCustomersSubtitle;

  /// No description provided for @emptyDebtsTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك ديون مسجلة 🎉'**
  String get emptyDebtsTitle;

  /// No description provided for @emptyDebtsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سجّل أول دين وابدأ المتابعة.'**
  String get emptyDebtsSubtitle;

  /// No description provided for @onboardingTitle1.
  ///
  /// In ar, this message translates to:
  /// **'لا تنسى ديون زبائنك'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In ar, this message translates to:
  /// **'احتفظ بسجل واضح لكل زبون ومبالغه.'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In ar, this message translates to:
  /// **'سجل الدين والدفعات بسهولة'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In ar, this message translates to:
  /// **'أضف دين أو دفعة خلال ثوانٍ فقط.'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In ar, this message translates to:
  /// **'وتابع المبلغ المتبقي في أي وقت'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In ar, this message translates to:
  /// **'ملخص سريع وكشف حساب جاهز للمشاركة.'**
  String get onboardingSubtitle3;

  /// No description provided for @getStarted.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get getStarted;

  /// No description provided for @darkMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الليلي'**
  String get darkMode;

  /// No description provided for @currency.
  ///
  /// In ar, this message translates to:
  /// **'العملة'**
  String get currency;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @reminderNotifications.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات التذكير'**
  String get reminderNotifications;

  /// No description provided for @appVersion.
  ///
  /// In ar, this message translates to:
  /// **'نسخة التطبيق'**
  String get appVersion;

  /// No description provided for @privacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In ar, this message translates to:
  /// **'شروط الاستخدام'**
  String get termsOfUse;

  /// No description provided for @backupComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي قريباً'**
  String get backupComingSoon;

  /// No description provided for @loadDemoData.
  ///
  /// In ar, this message translates to:
  /// **'تحميل بيانات تجريبية'**
  String get loadDemoData;

  /// No description provided for @demoDataLoaded.
  ///
  /// In ar, this message translates to:
  /// **'تم تحميل البيانات التجريبية'**
  String get demoDataLoaded;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @currencyIqd.
  ///
  /// In ar, this message translates to:
  /// **'د.ع'**
  String get currencyIqd;

  /// No description provided for @totalPayments.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الدفعات'**
  String get totalPayments;

  /// No description provided for @debtorCustomers.
  ///
  /// In ar, this message translates to:
  /// **'العملاء المدينون'**
  String get debtorCustomers;

  /// No description provided for @overdueDebts.
  ///
  /// In ar, this message translates to:
  /// **'الديون المتأخرة'**
  String get overdueDebts;

  /// No description provided for @topDebtors.
  ///
  /// In ar, this message translates to:
  /// **'أفضل 5 زبائن من حيث الدين'**
  String get topDebtors;

  /// No description provided for @qaidBannerTitle.
  ///
  /// In ar, this message translates to:
  /// **'تدير محلّك بشكل أكبر؟ 🚀'**
  String get qaidBannerTitle;

  /// No description provided for @qaidBannerBody.
  ///
  /// In ar, this message translates to:
  /// **'مع قيد تقدر تدير المبيعات والمشتريات والمخزون والديون والتقارير.'**
  String get qaidBannerBody;

  /// No description provided for @discoverQaid.
  ///
  /// In ar, this message translates to:
  /// **'اكتشف قيد'**
  String get discoverQaid;

  /// No description provided for @qaidPageTitle.
  ///
  /// In ar, this message translates to:
  /// **'كبر شغلك مع قيد'**
  String get qaidPageTitle;

  /// No description provided for @tryQaidFree.
  ///
  /// In ar, this message translates to:
  /// **'جرّب قيد مجاناً'**
  String get tryQaidFree;

  /// No description provided for @qaidFeatureSales.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات'**
  String get qaidFeatureSales;

  /// No description provided for @qaidFeaturePurchases.
  ///
  /// In ar, this message translates to:
  /// **'المشتريات'**
  String get qaidFeaturePurchases;

  /// No description provided for @qaidFeatureInventory.
  ///
  /// In ar, this message translates to:
  /// **'المخازن'**
  String get qaidFeatureInventory;

  /// No description provided for @qaidFeatureDebts.
  ///
  /// In ar, this message translates to:
  /// **'الديون'**
  String get qaidFeatureDebts;

  /// No description provided for @qaidFeatureInstallments.
  ///
  /// In ar, this message translates to:
  /// **'الأقساط'**
  String get qaidFeatureInstallments;

  /// No description provided for @qaidFeatureReports.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get qaidFeatureReports;

  /// No description provided for @qaidFeatureBarcode.
  ///
  /// In ar, this message translates to:
  /// **'الباركود'**
  String get qaidFeatureBarcode;

  /// No description provided for @qaidFeatureMobile.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق الموبايل'**
  String get qaidFeatureMobile;

  /// No description provided for @qaidFeatureBranches.
  ///
  /// In ar, this message translates to:
  /// **'الفروع'**
  String get qaidFeatureBranches;

  /// No description provided for @errorAmountRequired.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ مطلوب'**
  String get errorAmountRequired;

  /// No description provided for @errorAmountPositive.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ يجب أن يكون أكبر من صفر'**
  String get errorAmountPositive;

  /// No description provided for @errorAmountExceedsBalance.
  ///
  /// In ar, this message translates to:
  /// **'الدفعة أكبر من الدين المتبقي'**
  String get errorAmountExceedsBalance;

  /// No description provided for @errorNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'اسم الزبون مطلوب'**
  String get errorNameRequired;

  /// No description provided for @errorCustomerRequired.
  ///
  /// In ar, this message translates to:
  /// **'يجب اختيار زبون'**
  String get errorCustomerRequired;

  /// No description provided for @errorGeneric.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ، حاول مرة أخرى'**
  String get errorGeneric;

  /// No description provided for @lastActivity.
  ///
  /// In ar, this message translates to:
  /// **'آخر حركة'**
  String get lastActivity;

  /// No description provided for @statementTitle.
  ///
  /// In ar, this message translates to:
  /// **'كشف حساب الزبون'**
  String get statementTitle;

  /// No description provided for @statementName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get statementName;

  /// No description provided for @statementTotalDebt.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الدين'**
  String get statementTotalDebt;

  /// No description provided for @statementPaid.
  ///
  /// In ar, this message translates to:
  /// **'المدفوع'**
  String get statementPaid;

  /// No description provided for @statementRemaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي'**
  String get statementRemaining;

  /// No description provided for @statementLastPayment.
  ///
  /// In ar, this message translates to:
  /// **'آخر دفعة'**
  String get statementLastPayment;

  /// No description provided for @statementThanks.
  ///
  /// In ar, this message translates to:
  /// **'شكراً لتعاملك معنا.'**
  String get statementThanks;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @dismiss.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء'**
  String get dismiss;

  /// No description provided for @noResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noResults;

  /// No description provided for @privacyContent.
  ///
  /// In ar, this message translates to:
  /// **'بياناتك محلية على جهازك. لا نرسل بيانات الزبائن إلى أي خادم بدون موافقتك. لا نجمع بيانات شخصية غير ضرورية.'**
  String get privacyContent;

  /// No description provided for @termsContent.
  ///
  /// In ar, this message translates to:
  /// **'دَيني تطبيق مجاني لإدارة ديون الزبائن. استخدمه على مسؤوليتك. نحن غير مسؤولين عن فقدان البيانات قبل تفعيل النسخ الاحتياطي.'**
  String get termsContent;

  /// No description provided for @comingSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريباً'**
  String get comingSoon;

  /// No description provided for @descriptionHint.
  ///
  /// In ar, this message translates to:
  /// **'مثلاً: شراء بضاعة'**
  String get descriptionHint;

  /// No description provided for @selectDate.
  ///
  /// In ar, this message translates to:
  /// **'اختر التاريخ'**
  String get selectDate;

  /// No description provided for @none.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد'**
  String get none;

  /// No description provided for @iqdSuffix.
  ///
  /// In ar, this message translates to:
  /// **'د.ع'**
  String get iqdSuffix;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
