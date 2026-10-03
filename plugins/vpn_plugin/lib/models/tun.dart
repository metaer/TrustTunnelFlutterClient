import 'package:flutter/foundation.dart';
import 'package:vpn_plugin/models/tun_split_tunnel_mode.dart';

/// {@template tun}
/// TUN configuration .
///
/// This model provides:
/// - routes to include in tunneling ([includedRoutes]),
/// - routes to exclude ([excludedRoutes]),
/// - the interface MTU ([mtuSize]),
/// - and per-app routing ([splitTunnelMode], [splitTunnelApps]).
///
/// Values are forwarded to the backend as provided. Only [mtuSize] has a basic
/// invariant enforced locally.
/// {@endtemplate}
@immutable
final class Tun {
  /// {@template tun_included_routes}
  /// CIDR routes that should be routed through the virtual interface.
  ///
  /// Defaults include IPv4 default route and the common IPv6 global unicast
  /// range.
  /// {@endtemplate}
  final List<String> includedRoutes;

  /// {@template tun_excluded_routes}
  /// CIDR routes that should be excluded from tunneling.
  /// {@endtemplate}
  final List<String> excludedRoutes;

  /// {@template tun_mtu_size}
  /// MTU size for the virtual interface.
  ///
  /// Must be greater than zero. The constructor asserts this invariant.
  /// {@endtemplate}
  final int mtuSize;

  /// {@template tun_split_tunnel_mode_field}
  /// Per-app routing policy (Android only).
  ///
  /// Defaults to [TunSplitTunnelMode.off], meaning every application except the
  /// VPN application itself uses the tunnel.
  /// {@endtemplate}
  final TunSplitTunnelMode splitTunnelMode;

  /// {@template tun_split_tunnel_apps}
  /// Package names that [splitTunnelMode] applies to (Android only).
  ///
  /// Ignored when [splitTunnelMode] is [TunSplitTunnelMode.off].
  /// {@endtemplate}
  final List<String> splitTunnelApps;

  /// {@macro tun}
  const Tun({
    this.includedRoutes = const [
      '0.0.0.0/0',
      '2000::/3',
    ],
    this.excludedRoutes = const [],
    this.mtuSize = 1350,
    this.splitTunnelMode = TunSplitTunnelMode.off,
    this.splitTunnelApps = const [],
  }) : assert(mtuSize > 0, 'mtuSize must be greater than 0');

  @override
  String toString() =>
      'Tun(includedRoutes: $includedRoutes, excludedRoutes: $excludedRoutes, mtuSize: $mtuSize, '
      'splitTunnelMode: $splitTunnelMode, splitTunnelApps: $splitTunnelApps)';

  @override
  bool operator ==(covariant Tun other) {
    if (identical(this, other)) return true;

    return listEquals(other.includedRoutes, includedRoutes) &&
        listEquals(other.excludedRoutes, excludedRoutes) &&
        other.mtuSize == mtuSize &&
        other.splitTunnelMode == splitTunnelMode &&
        listEquals(other.splitTunnelApps, splitTunnelApps);
  }

  @override
  int get hashCode => Object.hashAll([
    Object.hashAll(includedRoutes),
    Object.hashAll(excludedRoutes),
    mtuSize,
    splitTunnelMode,
    Object.hashAll(splitTunnelApps),
  ]);
}
