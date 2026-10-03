/// {@template split_tunnel_mode}
/// Per-app routing policy (split tunneling), supported on Android only.
///
/// The mode is stored as a stable string identifier via [value], for example
/// in a local database. Do not change existing values.
/// {@endtemplate}
enum SplitTunnelMode {
  /// All apps use the VPN.
  off._('off'),

  /// Only the selected apps use the VPN; all other apps connect directly.
  include._('include'),

  /// The selected apps connect directly; all other apps use the VPN.
  exclude._('exclude')
  ;

  /// {@template split_tunnel_mode_value}
  /// Stable string identifier used for persistence.
  /// {@endtemplate}
  final String value;

  /// {@macro split_tunnel_mode}
  const SplitTunnelMode._(this.value);

  /// Returns the mode stored as [value], or [off] for `null` and unknown values.
  static SplitTunnelMode parse(String? value) => values.firstWhere(
    (mode) => mode.value == value,
    orElse: () => SplitTunnelMode.off,
  );
}
