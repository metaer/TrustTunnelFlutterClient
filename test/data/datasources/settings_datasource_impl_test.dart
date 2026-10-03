import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trusttunnel/data/database/app_database.dart' as db;
import 'package:trusttunnel/data/datasources/local_sources/settings_datasource_impl.dart';
import 'package:trusttunnel/data/model/split_tunnel_mode.dart';
import 'package:trusttunnel/data/model/split_tunnel_settings.dart';

void main() {
  late db.AppDatabase database;
  late SettingsDataSourceImpl dataSource;

  setUpAll(() {
    // Every test opens its own in-memory database.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    database = db.AppDatabase.inMemory(NativeDatabase.memory());
    dataSource = SettingsDataSourceImpl(database: database);
  });

  tearDown(() => database.close());

  Future<void> storeRaw(String key, String value) => database.appSettings.insertOnConflictUpdate(
    db.AppSettingsCompanion.insert(settingKey: key, value: value),
  );

  group('split tunnel settings', () {
    test('are off when nothing is stored', () async {
      expect(await dataSource.getSplitTunnelSettings(), const SplitTunnelSettings.off());
    });

    test('round-trip the mode and the apps in order', () async {
      const settings = SplitTunnelSettings(
        mode: SplitTunnelMode.include,
        apps: ['org.mozilla.firefox', 'com.android.chrome'],
      );

      await dataSource.setSplitTunnelSettings(settings);

      expect(await dataSource.getSplitTunnelSettings(), settings);
    });

    test('are replaced by a later write', () async {
      await dataSource.setSplitTunnelSettings(
        const SplitTunnelSettings(mode: SplitTunnelMode.include, apps: ['com.a', 'com.b']),
      );
      await dataSource.setSplitTunnelSettings(
        const SplitTunnelSettings(mode: SplitTunnelMode.exclude, apps: ['com.c']),
      );

      expect(
        await dataSource.getSplitTunnelSettings(),
        const SplitTunnelSettings(mode: SplitTunnelMode.exclude, apps: ['com.c']),
      );
    });

    test('keep the apps while the mode is off', () async {
      const settings = SplitTunnelSettings(mode: SplitTunnelMode.off, apps: ['com.a']);

      await dataSource.setSplitTunnelSettings(settings);

      expect(await dataSource.getSplitTunnelSettings(), settings);
    });

    test('read an unknown mode as off', () async {
      await storeRaw('split_tunnel_mode', 'everything');
      await storeRaw('split_tunnel_apps', '["com.a"]');

      expect(
        await dataSource.getSplitTunnelSettings(),
        const SplitTunnelSettings(mode: SplitTunnelMode.off, apps: ['com.a']),
      );
    });

    test('read a malformed app list as empty', () async {
      await storeRaw('split_tunnel_mode', 'exclude');

      for (final raw in ['not json', '{"a": 1}', '42', '']) {
        await storeRaw('split_tunnel_apps', raw);

        expect(
          await dataSource.getSplitTunnelSettings(),
          const SplitTunnelSettings(mode: SplitTunnelMode.exclude, apps: []),
          reason: raw,
        );
      }
    });

    test('drop non-string and duplicate entries', () async {
      await storeRaw('split_tunnel_mode', 'include');
      await storeRaw('split_tunnel_apps', '["com.a", 1, null, "com.b", "com.a"]');

      expect(
        await dataSource.getSplitTunnelSettings(),
        const SplitTunnelSettings(mode: SplitTunnelMode.include, apps: ['com.a', 'com.b']),
      );
    });

    test('do not touch the excluded routes', () async {
      final routes = await dataSource.getExcludedRoutes();

      await dataSource.setSplitTunnelSettings(
        const SplitTunnelSettings(mode: SplitTunnelMode.include, apps: ['com.a']),
      );

      expect(await dataSource.getExcludedRoutes(), routes);
    });
  });
}
