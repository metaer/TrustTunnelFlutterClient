import 'package:flutter/foundation.dart';
import 'package:trusttunnel/data/datasources/installed_apps_datasource.dart';
import 'package:trusttunnel/data/model/installed_app.dart';
import 'package:vpn_plugin/installed_apps_manager.dart';

/// {@template installed_apps_data_source_impl}
/// [InstalledAppsDataSource] backed by the VPN plugin's installed apps API.
///
/// The host API is implemented on Android only, so other platforms
/// short-circuit without calling it.
/// {@endtemplate}
class InstalledAppsDataSourceImpl implements InstalledAppsDataSource {
  final InstalledAppsManager _installedAppsManager;

  /// {@macro installed_apps_data_source_impl}
  InstalledAppsDataSourceImpl({
    required InstalledAppsManager installedAppsManager,
  }) : _installedAppsManager = installedAppsManager;

  @override
  Future<List<InstalledApp>> getInstalledApps() async {
    if (!_isSupported) return const [];

    final apps = await _installedAppsManager.getInstalledApps();

    return apps
        .map(
          (app) => InstalledApp(
            packageName: app.packageName,
            label: app.label,
            isSystem: app.isSystem,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<Uint8List?> getAppIcon(String packageName) async {
    if (!_isSupported) return null;

    return _installedAppsManager.getAppIcon(packageName: packageName);
  }

  bool get _isSupported => defaultTargetPlatform == TargetPlatform.android;
}
