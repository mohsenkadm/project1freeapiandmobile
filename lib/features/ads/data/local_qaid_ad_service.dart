import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../domain/entities/ad_banner.dart';
import '../domain/services/ad_service.dart';
import '../../settings/domain/repositories/settings_repository.dart';

class LocalQaidAdService implements AdService {
  LocalQaidAdService(this._db, this._settings);

  final AppDatabase _db;
  final SettingsRepository _settings;

  @override
  Stream<AdBanner?> watchHomeBanner() {
    return _settings.watchSettings().asyncMap((settings) async {
      if (settings.dismissedQaidBanner) return null;
      final row = await (_db.select(_db.adConfigurations)
            ..where((t) => t.id.equals(AppConstants.qaidBannerId)))
          .getSingleOrNull();
      if (row == null || !row.enabled) return null;
      return AdBanner(
        id: row.id,
        title: row.title,
        body: row.body,
        ctaLabel: row.ctaLabel,
        ctaUrl: row.ctaUrl,
        enabled: row.enabled,
      );
    });
  }

  @override
  Future<void> dismissBanner(String id) async {
    final current = await _settings.getSettings();
    await _settings.updateSettings(
      current.copyWith(dismissedQaidBanner: true),
    );
  }

  @override
  Uri? ctaUri(AdBanner banner) {
    final url = banner.ctaUrl;
    if (url == null || url.isEmpty) return null;
    return Uri.tryParse(url);
  }

  Future<void> openCta(AdBanner banner) async {
    final uri = ctaUri(banner);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
