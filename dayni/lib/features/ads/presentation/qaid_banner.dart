import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../domain/entities/ad_banner.dart';

final homeBannerProvider = StreamProvider<AdBanner?>((ref) {
  return ref.watch(adServiceProvider).watchHomeBanner();
});

class QaidBanner extends ConsumerWidget {
  const QaidBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(homeBannerProvider);
    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (banner) {
        if (banner == null) return const SizedBox.shrink();
        final l10n = AppLocalizations.of(context);
        return SoftCard(
          color: AppColors.secondary.withValues(alpha: 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      banner.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.dismiss,
                    onPressed: () =>
                        ref.read(adServiceProvider).dismissBanner(banner.id),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              Text(
                banner.body,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: FilledButton.tonal(
                  onPressed: () => context.push('/qaid'),
                  child: Text(banner.ctaLabel),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
