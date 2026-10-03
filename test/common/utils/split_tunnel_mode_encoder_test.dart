import 'package:flutter_test/flutter_test.dart';
import 'package:trusttunnel/common/utils/split_tunnel_mode_encoder.dart';
import 'package:trusttunnel/data/model/split_tunnel_mode.dart';
import 'package:vpn_plugin/models/tun_split_tunnel_mode.dart';

void main() {
  test('SplitTunnelModeEncoder maps every mode to the same backend value', () {
    final encoder = SplitTunnelModeEncoder();

    expect(encoder.convert(SplitTunnelMode.off), TunSplitTunnelMode.off);
    expect(encoder.convert(SplitTunnelMode.include), TunSplitTunnelMode.include);
    expect(encoder.convert(SplitTunnelMode.exclude), TunSplitTunnelMode.exclude);

    for (final mode in SplitTunnelMode.values) {
      expect(encoder.convert(mode).value, mode.value);
    }
  });
}
