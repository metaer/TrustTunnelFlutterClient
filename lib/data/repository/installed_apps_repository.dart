import 'dart:typed_data';

import 'package:trusttunnel/data/datasources/installed_apps_datasource.dart';
import 'package:trusttunnel/data/model/installed_app.dart';

abstract class InstalledAppsRepository {
  Future<List<InstalledApp>> getInstalledApps();

  Future<Uint8List?> getAppIcon(String packageName);
}

class InstalledAppsRepositoryImpl implements InstalledAppsRepository {
  final InstalledAppsDataSource _dataSource;

  InstalledAppsRepositoryImpl({
    required InstalledAppsDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<List<InstalledApp>> getInstalledApps() => _dataSource.getInstalledApps();

  @override
  Future<Uint8List?> getAppIcon(String packageName) => _dataSource.getAppIcon(packageName);
}
