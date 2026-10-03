import 'package:trusttunnel/data/model/installed_app.dart';

/// {@template installed_apps_filter}
/// Pure helpers that derive the rows of the split tunneling app list.
/// {@endtemplate}
abstract final class InstalledAppsFilter {
  /// Returns the [apps] whose label or package name matches [query], with the
  /// [pinned] package names first. The relative order of [apps] is preserved
  /// within both groups.
  static List<InstalledApp> visible({
    required List<InstalledApp> apps,
    required String query,
    Set<String> pinned = const {},
  }) {
    final matching = apps.where((app) => _matches(query, [app.label, app.packageName]));

    return [
      ...matching.where((app) => pinned.contains(app.packageName)),
      ...matching.where((app) => !pinned.contains(app.packageName)),
    ];
  }

  /// Returns the [selected] package names that are not among the installed
  /// [apps] and match [query], in selection order.
  static List<String> missing({
    required List<InstalledApp> apps,
    required List<String> selected,
    String query = '',
  }) {
    final installed = apps.map((app) => app.packageName).toSet();

    return selected
        .where((packageName) => !installed.contains(packageName) && _matches(query, [packageName]))
        .toList(growable: false);
  }

  /// Whether any of [values] contains [query], ignoring case and surrounding
  /// whitespace. An empty query matches everything.
  static bool _matches(String query, List<String> values) {
    final needle = query.trim().toLowerCase();

    return needle.isEmpty || values.any((value) => value.toLowerCase().contains(needle));
  }
}
