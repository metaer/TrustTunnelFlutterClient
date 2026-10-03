import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:trusttunnel/data/database/app_database.dart' as db;
import 'package:trusttunnel/data/datasources/settings_datasource.dart';
import 'package:trusttunnel/data/model/split_tunnel_mode.dart';
import 'package:trusttunnel/data/model/split_tunnel_settings.dart';

/// {@template settings_data_source_impl}
/// Drift-backed implementation of [SettingsDataSource].
///
/// Excluded routes are stored as a plain list of string rows. Updates replace
/// the entire list (delete all + insert all).
///
/// Split tunneling settings are stored in the key-value `app_settings` table:
/// the mode as its stable string value and the package names as a JSON array.
/// {@endtemplate}
class SettingsDataSourceImpl implements SettingsDataSource {
  static const _splitTunnelModeKey = 'split_tunnel_mode';
  static const _splitTunnelAppsKey = 'split_tunnel_apps';

  /// Drift database used for persistence.
  final db.AppDatabase database;

  /// {@macro settings_data_source_impl}
  SettingsDataSourceImpl({required this.database});

  /// {@macro settings_data_source_get_excluded_routes}
  @override
  Future<List<String>> getExcludedRoutes() async {
    final unparsedResult = await database.excludedRoutes.select().get();

    return unparsedResult.map((e) => e.value).toList();
  }

  /// {@macro settings_data_source_set_excluded_routes}
  ///
  /// The stored list is replaced atomically from the perspective of this method:
  /// all existing rows are removed, then the new set is inserted.
  @override
  Future<void> setExcludedRoutes(List<String> routes) async {
    await database.excludedRoutes.deleteAll();
    await database.excludedRoutes.insertAll(
      routes.map(
        (e) => db.ExcludedRoutesCompanion.insert(
          value: e,
        ),
      ),
    );
  }

  /// {@macro settings_data_source_get_split_tunnel_settings}
  ///
  /// Unknown modes are read as [SplitTunnelMode.off]; a malformed package list
  /// is read as empty.
  @override
  Future<SplitTunnelSettings> getSplitTunnelSettings() async {
    final mode = await _readSetting(_splitTunnelModeKey);
    final apps = await _readSetting(_splitTunnelAppsKey);

    return SplitTunnelSettings(
      mode: SplitTunnelMode.parse(mode),
      apps: _decodeApps(apps),
    );
  }

  /// {@macro settings_data_source_set_split_tunnel_settings}
  ///
  /// The mode and the package list are written in a single transaction.
  @override
  Future<void> setSplitTunnelSettings(SplitTunnelSettings settings) => database.transaction(() async {
    await _writeSetting(_splitTunnelModeKey, settings.mode.value);
    await _writeSetting(_splitTunnelAppsKey, jsonEncode(settings.apps));
  });

  Future<String?> _readSetting(String key) async {
    final row = await (database.appSettings.select()..where((t) => t.settingKey.equals(key))).getSingleOrNull();

    return row?.value;
  }

  Future<void> _writeSetting(String key, String value) => database.appSettings.insertOnConflictUpdate(
    db.AppSettingsCompanion.insert(
      settingKey: key,
      value: value,
    ),
  );

  static List<String> _decodeApps(String? encoded) {
    if (encoded == null || encoded.isEmpty) return const [];

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) return const [];

      return decoded.whereType<String>().toSet().toList(growable: false);
    } on FormatException {
      return const [];
    }
  }
}
