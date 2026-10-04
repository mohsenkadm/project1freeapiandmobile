import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../domain/entities/app_settings.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _shopController;
  late final TextEditingController _currencyController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _shopController = TextEditingController();
    _currencyController = TextEditingController();
  }

  @override
  void dispose() {
    _shopController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _save(AppSettings current) async {
    await ref.read(settingsRepositoryProvider).save(
          current.copyWith(
            shopName: _shopController.text.trim().isEmpty
                ? current.shopName
                : _shopController.text.trim(),
            currencySuffix: _currencyController.text.trim().isEmpty
                ? current.currencySuffix
                : _currencyController.text.trim(),
          ),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الإعدادات')),
    );
  }

  Future<void> _clearData() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف كل البيانات؟'),
        content: const Text(
          'سيتم حذف جميع المنتجات وسجل التسعيرات نهائياً. لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('حذف الكل'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(productRepositoryProvider).clear();
    await ref.read(historyRepositoryProvider).clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حذف البيانات')),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
          if (!_initialized) {
            _shopController.text = settings.shopName;
            _currencyController.text = settings.currencySuffix;
            _initialized = true;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.xxxl,
            ),
            children: [
              AppCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _shopController,
                      decoration: const InputDecoration(
                        labelText: 'اسم النشاط',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _currencyController,
                      decoration: const InputDecoration(
                        labelText: 'العملة',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton(
                        onPressed: () => _save(settings),
                        child: const Text('حفظ'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('الوضع الليلي'),
                      subtitle: Text(switch (settings.themeMode) {
                        AppThemeMode.dark => 'داكن',
                        AppThemeMode.light => 'فاتح',
                        AppThemeMode.system => 'حسب النظام',
                      }),
                      trailing: DropdownButton<AppThemeMode>(
                        value: settings.themeMode,
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(
                            value: AppThemeMode.dark,
                            child: Text('داكن'),
                          ),
                          DropdownMenuItem(
                            value: AppThemeMode.light,
                            child: Text('فاتح'),
                          ),
                          DropdownMenuItem(
                            value: AppThemeMode.system,
                            child: Text('النظام'),
                          ),
                        ],
                        onChanged: (mode) async {
                          if (mode == null) return;
                          await ref
                              .read(settingsRepositoryProvider)
                              .save(settings.copyWith(themeMode: mode));
                        },
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('الإشعارات'),
                      subtitle: const Text('تذكير خفيف للتسعير'),
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
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('طريقة حساب النسبة'),
                      subtitle: Text(
                        settings.marginMode == MarginMode.sellingMargin
                            ? 'هامش من سعر البيع'
                            : 'زيادة على التكلفة',
                      ),
                      trailing: DropdownButton<MarginMode>(
                        value: settings.marginMode,
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(
                            value: MarginMode.sellingMargin,
                            child: Text('هامش بيع'),
                          ),
                          DropdownMenuItem(
                            value: MarginMode.costMarkup,
                            child: Text('زيادة تكلفة'),
                          ),
                        ],
                        onChanged: (mode) async {
                          if (mode == null) return;
                          await ref
                              .read(settingsRepositoryProvider)
                              .save(settings.copyWith(marginMode: mode));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.delete_forever_rounded,
                          color: AppColors.danger),
                      title: const Text('حذف البيانات'),
                      onTap: _clearData,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.info_outline_rounded),
                      title: const Text('عن التطبيق'),
                      subtitle: Text(
                        '${AppConstants.appName} — الإصدار ${AppConstants.appVersion}',
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('سياسة الخصوصية'),
                      onTap: () => _openUrl(AppConstants.privacyPolicyUrl),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.rocket_launch_rounded,
                          color: AppColors.primary),
                      title: const Text('اكتشف قيد'),
                      onTap: () => context.push('/qayd'),
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
