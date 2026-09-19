import '../entities/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> get();

  Future<void> save(AppSettings settings);

  Future<void> clear();

  Stream<AppSettings> watch();
}
