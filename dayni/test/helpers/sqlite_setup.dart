import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/open.dart';

bool _sqliteReady = false;

void ensureSqliteLoaded() {
  if (_sqliteReady) return;
  if (Platform.isLinux) {
    open.overrideFor(OperatingSystem.linux, () {
      final candidates = [
        'libsqlite3.so.0',
        'libsqlite3.so',
        '/usr/lib/x86_64-linux-gnu/libsqlite3.so.0',
      ];
      Object? lastError;
      for (final path in candidates) {
        try {
          return DynamicLibrary.open(path);
        } catch (e) {
          lastError = e;
        }
      }
      throw StateError('Could not load sqlite3: $lastError');
    });
  }
  _sqliteReady = true;
}
