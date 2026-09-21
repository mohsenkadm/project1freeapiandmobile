import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Thin Hive box manager used by repositories.
class HiveStorage {
  HiveStorage();

  static const transactionsBox = 'transactions';
  static const cashCountsBox = 'cash_counts';
  static const settingsBox = 'settings';

  late final Box<String> transactions;
  late final Box<String> cashCounts;
  late final Box<String> settings;

  Future<void> init() async {
    await Hive.initFlutter();
    transactions = await Hive.openBox<String>(transactionsBox);
    cashCounts = await Hive.openBox<String>(cashCountsBox);
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
    await transactions.clear();
    await cashCounts.clear();
  }
}
