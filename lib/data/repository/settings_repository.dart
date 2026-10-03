import 'dart:async';

import 'package:trusttunnel/data/datasources/settings_datasource.dart';
import 'package:trusttunnel/data/model/split_tunnel_settings.dart';

abstract class SettingsRepository {
  Future<void> setExcludedRoutes(List<String> routes);

  Future<List<String>> getExcludedRoutes();

  Future<void> setSplitTunnelSettings(SplitTunnelSettings settings);

  Future<SplitTunnelSettings> getSplitTunnelSettings();
}

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDataSource _settingsDataSource;

  SettingsRepositoryImpl({
    required SettingsDataSource settingsDataSource,
  }) : _settingsDataSource = settingsDataSource;

  @override
  Future<List<String>> getExcludedRoutes() => _settingsDataSource.getExcludedRoutes();

  @override
  Future<void> setExcludedRoutes(List<String> routes) => _settingsDataSource.setExcludedRoutes(routes);

  @override
  Future<SplitTunnelSettings> getSplitTunnelSettings() => _settingsDataSource.getSplitTunnelSettings();

  @override
  Future<void> setSplitTunnelSettings(SplitTunnelSettings settings) =>
      _settingsDataSource.setSplitTunnelSettings(settings);
}
