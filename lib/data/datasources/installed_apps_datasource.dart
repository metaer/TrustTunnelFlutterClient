import 'dart:typed_data';

import 'package:trusttunnel/data/model/installed_app.dart';

/// {@template installed_apps_data_source}
/// Source of installed applications for per-app routing (split tunneling).
///
/// Only Android exposes installed applications; on other platforms the list is
/// empty and no icons are available.
/// {@endtemplate}
abstract class InstalledAppsDataSource {
  /// Loads every application with a launcher entry, excluding this application.
  Future<List<InstalledApp>> getInstalledApps();

  /// Loads the launcher icon of [packageName] as PNG bytes, or `null` if it is
  /// unavailable.
  Future<Uint8List?> getAppIcon(String packageName);
}
