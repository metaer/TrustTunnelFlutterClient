import 'dart:typed_data';

import 'package:vpn_plugin/platform_api.g.dart';

/// {@template installed_apps_manager}
/// Lists installed applications for per-app routing (split tunneling).
///
/// Backed by the Android package manager; other platforms do not implement the
/// host API, so callers must only use it on Android.
/// {@endtemplate}
abstract class InstalledAppsManager {
  /// Returns every application with a launcher entry, excluding this application.
  Future<List<PlatformInstalledApp>> getInstalledApps();

  /// Returns the launcher icon of [packageName] as PNG bytes, or `null` if the
  /// application is not installed.
  Future<Uint8List?> getAppIcon({
    required String packageName,
  });
}

/// {@macro installed_apps_manager}
class InstalledAppsManagerImpl implements InstalledAppsManager {
  /// {@macro installed_apps_manager}
  InstalledAppsManagerImpl() : _api = IInstalledApps();

  final IInstalledApps _api;

  @override
  Future<List<PlatformInstalledApp>> getInstalledApps() => _api.getInstalledApps();

  @override
  Future<Uint8List?> getAppIcon({required String packageName}) => _api.getAppIcon(packageName: packageName);
}
