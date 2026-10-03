import 'package:flutter/foundation.dart';

/// {@template installed_app}
/// An application installed on the device that has a launcher entry.
///
/// Instances are immutable and use value-based equality.
/// {@endtemplate}
@immutable
class InstalledApp {
  /// Unique application identifier (Android package name).
  final String packageName;

  /// User-visible application name.
  final String label;

  /// Whether the application is preinstalled (a system app or an update of one).
  final bool isSystem;

  /// {@macro installed_app}
  const InstalledApp({
    required this.packageName,
    required this.label,
    required this.isSystem,
  });

  @override
  int get hashCode => Object.hash(
    packageName,
    label,
    isSystem,
  );

  @override
  String toString() =>
      'InstalledApp('
      'packageName: $packageName, '
      'label: $label, '
      'isSystem: $isSystem'
      ')';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InstalledApp &&
        other.packageName == packageName &&
        other.label == label &&
        other.isSystem == isSystem;
  }
}
