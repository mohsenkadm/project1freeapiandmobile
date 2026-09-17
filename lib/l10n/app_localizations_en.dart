// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Dayni';

  @override
  String get welcomeGreeting => 'Welcome 👋';

  @override
  String get totalDebts => 'Total debts';

  @override
  String get customers => 'Customers';

  @override
  String get customersWithDebt => 'With debts';

  @override
  String get todaysPayments => 'Today\'s payments';

  @override
  String get recentDebts => 'Recent debts';

  @override
  String get addDebt => 'Add debt';

  @override
  String get addCustomer => 'Add customer';

  @override
  String get saveCustomer => 'Save customer';

  @override
  String get customerName => 'Customer name';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get notes => 'Notes';

  @override
  String get required => 'Required';

  @override
  String get home => 'Home';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get add => 'Add';

  @override
  String get recordPayment => 'Record payment';

  @override
  String get saveDebt => 'Save debt';

  @override
  String get amount => 'Amount';

  @override
  String get debtDescription => 'Debt description';

  @override
  String get debtDate => 'Debt date';

  @override
  String get dueDate => 'Due date';

  @override
  String get optional => 'Optional';

  @override
  String get selectCustomer => 'Select customer';

  @override
  String get debtSavedSuccess => 'Debt saved successfully';

  @override
  String get customerSavedSuccess => 'Customer saved successfully';

  @override
  String get paymentSavedSuccess => 'Payment recorded successfully';

  @override
  String get totalDebt => 'Total debt';

  @override
  String get paid => 'Paid';

  @override
  String get remaining => 'Remaining';

  @override
  String get sendStatement => 'Send statement';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get cash => 'Cash';

  @override
  String get transfer => 'Transfer';

  @override
  String get other => 'Other';

  @override
  String get savePayment => 'Record payment';

  @override
  String get searchHint => 'Search by name or phone';

  @override
  String get customerCount => 'Customer count';

  @override
  String get filterAll => 'All';

  @override
  String get filterWithDebt => 'With debts';

  @override
  String get filterSettled => 'Settled';

  @override
  String get filterOverdue => 'Overdue';

  @override
  String get filterNoDebt => 'No debt';

  @override
  String get statusHasDebt => 'Has debt';

  @override
  String get statusSettled => 'Settled';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get statusNoDebt => 'No debt';

  @override
  String get dueToday => 'Due today';

  @override
  String get overdue => 'Overdue';

  @override
  String daysRemaining(int days) {
    return '$days days left';
  }

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get dayAgo => '1 day ago';

  @override
  String get today => 'Today';

  @override
  String get newDebt => 'New debt';

  @override
  String get payment => 'Payment';

  @override
  String get emptyCustomersTitle => 'No customers yet';

  @override
  String get emptyCustomersSubtitle =>
      'Add your first customer and start organizing debts.';

  @override
  String get emptyDebtsTitle => 'No debts recorded 🎉';

  @override
  String get emptyDebtsSubtitle => 'Record your first debt to start tracking.';

  @override
  String get onboardingTitle1 => 'Never forget customer debts';

  @override
  String get onboardingSubtitle1 => 'Keep a clear record for every customer.';

  @override
  String get onboardingTitle2 => 'Record debts and payments easily';

  @override
  String get onboardingSubtitle2 => 'Add a debt or payment in seconds.';

  @override
  String get onboardingTitle3 => 'Track remaining balance anytime';

  @override
  String get onboardingSubtitle3 => 'Quick summary and shareable statements.';

  @override
  String get getStarted => 'Get started';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get currency => 'Currency';

  @override
  String get language => 'Language';

  @override
  String get reminderNotifications => 'Reminder notifications';

  @override
  String get appVersion => 'App version';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get termsOfUse => 'Terms of use';

  @override
  String get backupComingSoon => 'Backup coming soon';

  @override
  String get loadDemoData => 'Load demo data';

  @override
  String get demoDataLoaded => 'Demo data loaded';

  @override
  String get arabic => 'Arabic';

  @override
  String get currencyIqd => 'IQD';

  @override
  String get totalPayments => 'Total payments';

  @override
  String get debtorCustomers => 'Debtor customers';

  @override
  String get overdueDebts => 'Overdue debts';

  @override
  String get topDebtors => 'Top 5 customers by debt';

  @override
  String get qaidBannerTitle => 'Growing your shop? 🚀';

  @override
  String get qaidBannerBody =>
      'With Qaid you can manage sales, purchases, inventory, debts, and reports.';

  @override
  String get discoverQaid => 'Discover Qaid';

  @override
  String get qaidPageTitle => 'Grow your business with Qaid';

  @override
  String get tryQaidFree => 'Try Qaid for free';

  @override
  String get qaidFeatureSales => 'Sales';

  @override
  String get qaidFeaturePurchases => 'Purchases';

  @override
  String get qaidFeatureInventory => 'Inventory';

  @override
  String get qaidFeatureDebts => 'Debts';

  @override
  String get qaidFeatureInstallments => 'Installments';

  @override
  String get qaidFeatureReports => 'Reports';

  @override
  String get qaidFeatureBarcode => 'Barcode';

  @override
  String get qaidFeatureMobile => 'Mobile app';

  @override
  String get qaidFeatureBranches => 'Branches';

  @override
  String get errorAmountRequired => 'Amount is required';

  @override
  String get errorAmountPositive => 'Amount must be greater than zero';

  @override
  String get errorAmountExceedsBalance => 'Payment exceeds remaining balance';

  @override
  String get errorNameRequired => 'Customer name is required';

  @override
  String get errorCustomerRequired => 'Please select a customer';

  @override
  String get errorGeneric => 'Something went wrong, try again';

  @override
  String get lastActivity => 'Last activity';

  @override
  String get statementTitle => 'Customer statement';

  @override
  String get statementName => 'Name';

  @override
  String get statementTotalDebt => 'Total debt';

  @override
  String get statementPaid => 'Paid';

  @override
  String get statementRemaining => 'Remaining';

  @override
  String get statementLastPayment => 'Last payment';

  @override
  String get statementThanks => 'Thank you for your business.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get noResults => 'No results';

  @override
  String get privacyContent =>
      'Your data stays on your device. We do not send customer data to any server without your consent. We do not collect unnecessary personal data.';

  @override
  String get termsContent =>
      'Dayni is a free app for managing customer debts. Use at your own risk. We are not responsible for data loss before backup is enabled.';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get descriptionHint => 'e.g. Purchased goods';

  @override
  String get selectDate => 'Select date';

  @override
  String get none => 'None';

  @override
  String get iqdSuffix => 'IQD';
}
