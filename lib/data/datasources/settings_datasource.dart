import 'package:trusttunnel/data/model/split_tunnel_settings.dart';

/// {@template settings_data_source}
/// Persistence interface for application-level settings related to VPN.
///
/// This data source stores and retrieves settings that are not tied to a
/// particular server or routing profile. Currently it manages excluded routes
/// and per-app routing (split tunneling) used in VPN/TUN configuration.
/// {@endtemplate}
abstract class SettingsDataSource {
  /// {@template settings_data_source_set_excluded_routes}
  /// Persists the list of routes excluded from VPN/TUN routing.
  ///
  /// Implementations may replace the stored list entirely.
  /// {@endtemplate}
  Future<void> setExcludedRoutes(List<String> routes);

  /// {@template settings_data_source_get_excluded_routes}
  /// Loads the currently stored excluded routes list.
  /// {@endtemplate}
  Future<List<String>> getExcludedRoutes();

  /// {@template settings_data_source_set_split_tunnel_settings}
  /// Persists the per-app routing (split tunneling) settings, replacing the
  /// stored ones.
  /// {@endtemplate}
  Future<void> setSplitTunnelSettings(SplitTunnelSettings settings);

  /// {@template settings_data_source_get_split_tunnel_settings}
  /// Loads the stored per-app routing (split tunneling) settings.
  ///
  /// Returns [SplitTunnelSettings.off] when nothing has been stored yet.
  /// {@endtemplate}
  Future<SplitTunnelSettings> getSplitTunnelSettings();
}
