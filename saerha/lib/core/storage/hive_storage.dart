import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Thin Hive box manager used by repositories.
class HiveStorage {
  HiveStorage();

  static const productsBox = 'products';
  static const historyBox = 'history';
  static const settingsBox = 'settings';

  late final Box<String> products;
  late final Box<String> history;
  late final Box<String> settings;

  Future<void> init() async {
    await Hive.initFlutter();
    products = await Hive.openBox<String>(productsBox);
    history = await Hive.openBox<String>(historyBox);
    settings = await Hive.openBox<String>(settingsBox);
  }

  Map<String, dynamic>? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e, st) {
      debugPrint('Hive decode failed: $e\n$st');
      return null;
    }
  }

  String encode(Map<String, dynamic> json) => jsonEncode(json);

  Future<void> clearAllData() async {
    await products.clear();
    await history.clear();
  }
}
