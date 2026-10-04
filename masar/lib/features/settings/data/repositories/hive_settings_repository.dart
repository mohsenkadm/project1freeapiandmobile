import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class HiveSettingsRepository implements SettingsRepository {
  HiveSettingsRepository(this._storage);

  final HiveStorage _storage;
  static const _key = 'app_settings';

  @override
  Future<AppSettings> get() async {
    final json = _storage.decode(_storage.settings.get(_key));
    if (json == null) return const AppSettings();
    return AppSettings.fromJson(json);
  }

  @override
  Future<void> save(AppSettings settings) async {
    await _storage.settings.put(_key, _storage.encode(settings.toJson()));
  }

  @override
  Future<int> takeNextOrderNumber() async {
    final current = await get();
    final number = current.nextOrderNumber;
    await save(
      current.copyWith(
        nextOrderNumber: number + 1,
      ),
    );
    if (number < AppConstants.firstOrderNumber) {
      return AppConstants.firstOrderNumber;
    }
    return number;
  }
}
