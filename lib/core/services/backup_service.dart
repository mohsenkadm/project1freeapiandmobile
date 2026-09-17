/// Abstraction for future backup / restore.
abstract class BackupService {
  Future<bool> get isAvailable;
  Future<void> exportBackup();
  Future<void> importBackup();
}

class ComingSoonBackupService implements BackupService {
  @override
  Future<bool> get isAvailable async => false;

  @override
  Future<void> exportBackup() async {
    throw UnsupportedError('Backup coming soon');
  }

  @override
  Future<void> importBackup() async {
    throw UnsupportedError('Backup coming soon');
  }
}
