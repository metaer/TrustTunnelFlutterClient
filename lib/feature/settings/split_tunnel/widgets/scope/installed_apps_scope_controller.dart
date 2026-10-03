import 'dart:typed_data';

import 'package:trusttunnel/common/error/model/presentation_exception.dart';
import 'package:trusttunnel/data/model/installed_app.dart';

abstract class InstalledAppsScopeController {
  /// Installed applications sorted by label.
  abstract final List<InstalledApp> apps;
  abstract final String query;

  /// Whether [apps] has been loaded successfully at least once.
  abstract final bool isLoaded;
  abstract final bool loading;

  abstract final PresentationException? error;

  abstract final void Function() fetch;
  abstract final void Function(String query) setQuery;

  /// Returns the cached launcher icon request of a package.
  abstract final Future<Uint8List?> Function(String packageName) iconOf;
}
