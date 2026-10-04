import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/providers.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../domain/entities/app_settings.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _shopCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _currencyCtrl = TextEditingController();
  bool _loaded = false;

  @override
  void dispose() {
    _shopCtrl.dispose();
    _phoneCtrl.dispose();
    _currencyCtrl.dispose();
    super.dispose();
  }

  void _hydrate(AppSettings settings) {
    if (_loaded) return;
    _shopCtrl.text = settings.shopName;
    _phoneCtrl.text = settings.phone;
    _currencyCtrl.text = settings.currencySuffix;
    _loaded = true;
  }

  Future<void> _saveBasics(AppSettings current) async {
    final updated = current.copyWith(
      shopName: _shopCtrl.text.trim().isEmpty ? 'نشاطي' : _shopCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      currencySuffix: _currencyCtrl.text.trim().isEmpty
          ? AppConstants.currencySuffix
          : _currencyCtrl.text.trim(),
    );
    await ref.read(settingsRepositoryProvider).save(updated);
    if (mounted) context.showMessage('تم حفظ الإعدادات');
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('هل أنت متأكد؟'),
        content: const Text(
          'سيتم حذف جميع الطلبات والزبائن والمنتجات ولا يمكن التراجع.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('حذف البيانات'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final storage = ref.read(hiveStorageProvider);
    await storage.clearAllData();
    final settings = await ref.read(settingsRepositoryProvider).get();
    await ref.read(settingsRepositoryProvider).save(
          settings.copyWith(
            nextOrderNumber: AppConstants.firstOrderNumber,
            qaydPromoDismissed: false,
          ),
        );
    if (mounted) context.showMessage('تم حذف جميع البيانات');
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (settings) {
          _hydrate(settings);
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              AppCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _shopCtrl,
                      decoration: const InputDecoration(
                        labelText: 'اسم النشاط',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _currencyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'العملة',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
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
                      subtitle: const Text('Dark Mode هو التصميم الأساسي'),
                      value: settings.themeMode == AppThemeMode.dark,
                      onChanged: (v) async {
                        await ref.read(settingsRepositoryProvider).save(
                              settings.copyWith(
                                themeMode:
                                    v ? AppThemeMode.dark : AppThemeMode.light,
                              ),
                            );
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('الإشعارات'),
                      subtitle: const Text('تذكير يومي اختياري بالطلبات'),
                      value: settings.notificationsEnabled,
                      onChanged: (v) async {
                        await ref.read(settingsRepositoryProvider).save(
                              settings.copyWith(notificationsEnabled: v),
                            );
                        await refreshNotifications(ref);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('إدارة البيانات',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: _confirmDelete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('حذف جميع البيانات'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                onTap: () => context.push('/qayd'),
                child: const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.auto_awesome_rounded,
                      color: AppColors.primary),
                  title: Text('اكتشف قيد'),
                  subtitle: Text('مسار يدير طلباتك. قيد يدير تجارتك.'),
                  trailing: Icon(Icons.chevron_left_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('عن مسار',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${AppConstants.appName} — ${AppConstants.tagline}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'الإصدار ${AppConstants.appVersion}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'الخصوصية: كل بياناتك محفوظة محلياً على جهازك فقط في هذه النسخة. لا يتم إرسال بيانات الزبائن إلى أي خادم.',
                      style: Theme.of(context).textTheme.bodySmall,
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
