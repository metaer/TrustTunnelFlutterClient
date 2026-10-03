enum SplitTunnelAspect {
  /// The draft, the persisted settings or the error changed (settings screen).
  data,

  /// The persisted settings or their loaded flag changed (VPN configuration).
  settings,
  loading,
}
