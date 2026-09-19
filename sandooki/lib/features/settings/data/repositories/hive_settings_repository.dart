import 'dart:async';

import '../../../../core/storage/hive_storage.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class HiveSettingsRepository implements SettingsRepository {
  HiveSettingsRepository(this._storage);

  final HiveStorage _storage;
  static const _key = 'app_settings';
  final _controller = StreamController<AppSettings>.broadcast();

  @override
  Future<void> clear() async {
    await _storage.settings.delete(_key);
    _controller.add(const AppSettings());
  }

  @override
  Future<AppSettings> get() async {
    final raw = _storage.settings.get(_key);
    final map = _storage.decode(raw);
    if (map == null) return const AppSettings();
    return AppSettings.fromJson(map);
  }

  @override
  Future<void> save(AppSettings settings) async {
    await _storage.settings.put(_key, _storage.encode(settings.toJson()));
    _controller.add(settings);
  }

  @override
  Stream<AppSettings> watch() async* {
    yield await get();
    yield* _controller.stream;
  }
}
