import '../entities/ad_banner.dart';

abstract class AdService {
  Stream<AdBanner?> watchHomeBanner();
  Future<void> dismissBanner(String id);
  Uri? ctaUri(AdBanner banner);
}
