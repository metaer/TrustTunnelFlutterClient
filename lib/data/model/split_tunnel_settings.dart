import 'package:flutter/foundation.dart';
import 'package:trusttunnel/data/model/split_tunnel_mode.dart';

/// {@template split_tunnel_settings}
/// Per-app routing (split tunneling) settings, supported on Android only.
///
/// [apps] holds the package names that [mode] applies to. The list is kept
/// while [mode] is [SplitTunnelMode.off], so switching the mode back restores
/// the previous selection.
///
/// Instances are immutable and use value-based equality.
/// {@endtemplate}
@immutable
class SplitTunnelSettings {
  /// Per-app routing policy.
  final SplitTunnelMode mode;

  /// Package names the [mode] applies to, unique and in selection order.
  ///
  /// The list is expected to be treated as immutable by callers.
  final List<String> apps;

  /// {@macro split_tunnel_settings}
  const SplitTunnelSettings({
    required this.mode,
    required this.apps,
  });

  /// Settings that route every app through the VPN.
  const SplitTunnelSettings.off() : mode = SplitTunnelMode.off, apps = const [];

  /// Whether per-app routing is active.
  bool get isEnabled => mode != SplitTunnelMode.off;

  /// Whether these settings route the same apps through the VPN as [other].
  ///
  /// The order of [apps] does not matter, and [apps] is ignored when routing
  /// is [SplitTunnelMode.off].
  bool isEquivalentTo(SplitTunnelSettings other) =>
      mode == other.mode && (!isEnabled || setEquals(apps.toSet(), other.apps.toSet()));

  @override
  int get hashCode => Object.hash(
    mode,
    Object.hashAll(apps),
  );

  @override
  String toString() =>
      'SplitTunnelSettings('
      'mode: $mode, '
      'splitTunnelApps: $apps'
      ')';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SplitTunnelSettings && other.mode == mode && listEquals(other.apps, apps);
  }

  /// Creates a copy of these settings with the given fields replaced.
  ///
  /// Fields that are not provided retain their original values.
  SplitTunnelSettings copyWith({
    SplitTunnelMode? mode,
    List<String>? apps,
  }) => SplitTunnelSettings(
    mode: mode ?? this.mode,
    apps: apps ?? this.apps,
  );
}
