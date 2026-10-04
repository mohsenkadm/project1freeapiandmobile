import '../entities/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> get();
  Future<void> save(AppSettings settings);
  Stream<AppSettings> watch();
  Future<void> clear();
}
