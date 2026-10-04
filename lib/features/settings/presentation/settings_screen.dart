import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/common_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _showTextDialog(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(body)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context).close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.errorGeneric)),
        data: (settings) {
          final isDark = settings.themeMode == ThemeMode.dark ||
              (settings.themeMode == ThemeMode.system &&
                  MediaQuery.platformBrightnessOf(context) == Brightness.dark);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              SoftCard(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.darkMode),
                  value: settings.themeMode == ThemeMode.dark ||
                      (settings.themeMode == ThemeMode.system && isDark),
                  onChanged: (enabled) async {
                    final repo = ref.read(settingsRepositoryProvider);
                    await repo.updateSettings(
                      settings.copyWith(
                        themeMode:
                            enabled ? ThemeMode.dark : ThemeMode.light,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SoftCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.currency),
                  trailing: Text(
                    l10n.currencyIqd,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SoftCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.language),
                  trailing: Text(
                    l10n.arabic,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SoftCard(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.reminderNotifications),
                  subtitle: Text(l10n.comingSoon),
                  value: settings.remindersEnabled,
                  onChanged: (enabled) async {
                    final repo = ref.read(settingsRepositoryProvider);
                    await repo.updateSettings(
                      settings.copyWith(remindersEnabled: enabled),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SoftCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.backupComingSoon),
                  trailing: const Icon(Icons.cloud_upload_outlined),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.comingSoon)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SoftCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.loadDemoData),
                  trailing: const Icon(Icons.dataset_outlined),
                  onTap: () async {
                    await ref.read(demoDataSeederProvider).seed();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.demoDataLoaded)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SoftCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.appVersion),
                  trailing: const Text(
                    AppConstants.appVersion,
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SoftCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.privacyPolicy),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () => _showTextDialog(
                    context,
                    title: l10n.privacyPolicy,
                    body: l10n.privacyContent,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SoftCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.termsOfUse),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () => _showTextDialog(
                    context,
                    title: l10n.termsOfUse,
                    body: l10n.termsContent,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
