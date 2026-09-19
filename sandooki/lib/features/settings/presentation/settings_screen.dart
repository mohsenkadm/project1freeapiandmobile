import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../domain/entities/app_settings.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _shopName;
  late final TextEditingController _opening;
  bool _initialized = false;

  @override
  void dispose() {
    if (_initialized) {
      _shopName.dispose();
      _opening.dispose();
    }
    super.dispose();
  }

  void _ensureControllers(AppSettings settings) {
    if (_initialized) return;
    _shopName = TextEditingController(text: settings.shopName);
    _opening = TextEditingController(
      text: settings.openingBalance <= 0
          ? ''
          : settings.openingBalance.round().toString().replaceAllMapped(
                RegExp(r'\B(?=(\d{3})+(?!\d))'),
                (m) => ',',
              ),
    );
    _initialized = true;
  }

  Future<void> _saveBasics(AppSettings current) async {
    final opening = AmountInput.parseAmount(_opening.text) ?? 0;
    await ref.read(settingsRepositoryProvider).save(
          current.copyWith(
            shopName: _shopName.text.trim().isEmpty
                ? 'محلي'
                : _shopName.text.trim(),
            openingBalance: opening.toDouble(),
            currencySuffix: AppConstants.currencySuffix,
          ),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الإعدادات')),
    );
  }

  Future<void> _clearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف جميع البيانات؟'),
        content: const Text(
          'راح تنحذف كل الحركات والجرد. الإعدادات تبقى. هالعملية ما تنعكس.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(transactionRepositoryProvider).clearAll();
    await ref.read(cashRepositoryProvider).clearAll();
    ref.invalidate(historySummariesProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حذف جميع البيانات')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('حدث خطأ، حاول مرة أخرى.')),
        data: (settings) {
          _ensureControllers(settings);
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              120,
            ),
            children: [
              AppCard(
                child: Column(
                  children: [
                    AppTextField(
                      controller: _shopName,
                      label: 'اسم المحل',
                      hint: 'محلي',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AmountInput(
                      controller: _opening,
                      label: 'الرصيد الافتتاحي',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('العملة'),
                      subtitle: Text(AppConstants.currencySuffix),
                      trailing: const Icon(Icons.lock_outline, size: 18),
                    ),
                    PrimaryButton(
                      label: 'حفظ',
                      onPressed: () => _saveBasics(settings),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('الوضع الليلي'),
                      subtitle: const Text('التصميم الأساسي المفضل'),
                      value: settings.themeMode == AppThemeMode.dark ||
                          (settings.themeMode == AppThemeMode.system &&
                              Theme.of(context).brightness == Brightness.dark),
                      onChanged: (dark) async {
                        await ref.read(settingsRepositoryProvider).save(
                              settings.copyWith(
                                themeMode: dark
                                    ? AppThemeMode.dark
                                    : AppThemeMode.light,
                              ),
                            );
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('الإشعارات'),
                      subtitle: const Text('تذكير بجرد الصندوق مساءً'),
                      value: settings.notificationsEnabled,
                      onChanged: (enabled) async {
                        await ref.read(settingsRepositoryProvider).save(
                              settings.copyWith(notificationsEnabled: enabled),
                            );
                        await ref
                            .read(notificationServiceProvider)
                            .scheduleDailyReminder(enabled: enabled);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_forever_rounded,
                      color: AppColors.danger),
                  title: const Text('حذف جميع البيانات'),
                  subtitle: const Text('مع تأكيد قبل الحذف'),
                  onTap: _clearData,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('عن التطبيق',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${AppConstants.appName} — ${AppConstants.tagline}\nالإصدار ${AppConstants.appVersion}\nكل بياناتك تبقى على جهازك فقط.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
