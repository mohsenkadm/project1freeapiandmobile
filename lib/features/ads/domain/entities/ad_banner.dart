import 'package:equatable/equatable.dart';

class AdBanner extends Equatable {
  const AdBanner({
    required this.id,
    required this.title,
    required this.body,
    required this.ctaLabel,
    this.ctaUrl,
    this.enabled = true,
  });

  final String id;
  final String title;
  final String body;
  final String ctaLabel;
  final String? ctaUrl;
  final bool enabled;

  @override
  List<Object?> get props => [id, title, body, ctaLabel, ctaUrl, enabled];
}
