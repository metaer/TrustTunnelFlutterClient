/// {@template tun_split_tunnel_mode}
/// Per-app routing policy of the virtual interface (split tunneling).
///
/// The mode decides which applications send their traffic through the TUN
/// interface; the package names it applies to are listed in
/// [Tun.splitTunnelApps].
///
/// Only the Android backend supports per-app routing. Other backends ignore
/// the value, so it should stay [off] there.
/// {@endtemplate}
enum TunSplitTunnelMode {
  /// All applications use the tunnel (the VPN application itself never does).
  off('off'),

  /// Only the listed applications use the tunnel.
  include('include'),

  /// All applications except the listed ones use the tunnel.
  exclude('exclude');

  /// {@template tun_split_tunnel_mode_value}
  /// Backend string representation of the mode.
  /// {@endtemplate}
  final String value;

  /// {@macro tun_split_tunnel_mode}
  const TunSplitTunnelMode(this.value);
}
