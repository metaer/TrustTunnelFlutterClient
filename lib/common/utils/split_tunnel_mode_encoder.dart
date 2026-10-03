import 'dart:convert';

import 'package:trusttunnel/data/model/split_tunnel_mode.dart';
import 'package:vpn_plugin/models/tun_split_tunnel_mode.dart';

class SplitTunnelModeEncoder extends Converter<SplitTunnelMode, TunSplitTunnelMode> {
  @override
  TunSplitTunnelMode convert(SplitTunnelMode splitTunnelMode) => switch (splitTunnelMode) {
    SplitTunnelMode.off => TunSplitTunnelMode.off,
    SplitTunnelMode.include => TunSplitTunnelMode.include,
    SplitTunnelMode.exclude => TunSplitTunnelMode.exclude,
  };
}
