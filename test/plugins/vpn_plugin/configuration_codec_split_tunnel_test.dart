import 'package:flutter_test/flutter_test.dart';
import 'package:vpn_plugin/domain/configuration_codec.dart';
import 'package:vpn_plugin/models/configuration.dart';
import 'package:vpn_plugin/models/endpoint.dart';
import 'package:vpn_plugin/models/socks.dart';
import 'package:vpn_plugin/models/tun.dart';
import 'package:vpn_plugin/models/tun_split_tunnel_mode.dart';
import 'package:vpn_plugin/models/upstream_protocol.dart';
import 'package:vpn_plugin/models/vpn_mode.dart';

void main() {
  const codec = ConfigurationCodec();

  Configuration configurationWith(Tun tun) => Configuration(
    vpnMode: VpnMode.general,
    endpoint: const Endpoint(
      name: 'Server',
      hostName: 'vpn.example.org',
      username: 'user',
      password: 'secret',
      upStreamProtocol: UpStreamProtocol.http2,
      hasIpv6: false,
    ),
    tun: tun,
    socks: const Socks(),
  );

  List<String> tunSectionLines(String encoded) {
    final lines = encoded.split('\n');
    final start = lines.indexOf('[listener.tun]');
    final end = lines.indexWhere((line) => line.startsWith('['), start + 1);

    return lines.sublist(start + 1, end == -1 ? lines.length : end).where((line) => line.trim().isNotEmpty).toList();
  }

  group('ConfigurationEncoder split tunneling', () {
    test('writes off and an empty list by default', () {
      final encoded = codec.encode(configurationWith(const Tun()));

      expect(
        tunSectionLines(encoded),
        containsAllInOrder(<String>[
          'mtu_size = 1350',
          'split_tunnel_mode = "off"',
          'split_tunnel_apps = []',
        ]),
      );
    });

    test('writes the mode and the package names', () {
      final encoded = codec.encode(
        configurationWith(
          const Tun(
            splitTunnelMode: TunSplitTunnelMode.include,
            splitTunnelApps: ['com.android.chrome', 'org.mozilla.firefox'],
          ),
        ),
      );

      expect(
        tunSectionLines(encoded),
        containsAll(<String>[
          'split_tunnel_mode = "include"',
          'split_tunnel_apps = ["com.android.chrome", "org.mozilla.firefox"]',
        ]),
      );
    });
  });

  group('ConfigurationDecoder split tunneling', () {
    for (final mode in TunSplitTunnelMode.values) {
      test('round-trips ${mode.name}', () {
        final tun = Tun(
          splitTunnelMode: mode,
          splitTunnelApps: const ['com.example.one', 'com.example.two'],
        );

        final decoded = codec.decode(codec.encode(configurationWith(tun)));

        expect(decoded.tun, tun);
      });
    }

    test('falls back to off for an unknown mode', () {
      final encoded = codec
          .encode(configurationWith(const Tun(splitTunnelMode: TunSplitTunnelMode.exclude)))
          .replaceFirst('split_tunnel_mode = "exclude"', 'split_tunnel_mode = "everything"');

      final decoded = codec.decode(encoded);

      expect(decoded.tun.splitTunnelMode, TunSplitTunnelMode.off);
    });

    test('uses defaults when the keys are absent', () {
      final encoded = codec
          .encode(configurationWith(const Tun()))
          .split('\n')
          .where((line) => !line.startsWith('split_tunnel_'))
          .join('\n');

      final decoded = codec.decode(encoded);

      expect(decoded.tun.splitTunnelMode, TunSplitTunnelMode.off);
      expect(decoded.tun.splitTunnelApps, isEmpty);
    });
  });

  group('Tun', () {
    test('equality and hash code include the split tunneling fields', () {
      // Distinct, non-canonicalized instances.
      final a = Tun(splitTunnelMode: TunSplitTunnelMode.exclude, splitTunnelApps: ['com.example.app'].toList());
      final b = Tun(splitTunnelMode: TunSplitTunnelMode.exclude, splitTunnelApps: ['com.example.app'].toList());

      expect(identical(a, b), isFalse);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(const Tun(splitTunnelMode: TunSplitTunnelMode.include, splitTunnelApps: ['com.example.app'])));
      expect(a, isNot(const Tun(splitTunnelMode: TunSplitTunnelMode.exclude)));
    });

    test('toString includes the split tunneling fields', () {
      expect(
        const Tun(splitTunnelMode: TunSplitTunnelMode.include, splitTunnelApps: ['com.example.app']).toString(),
        allOf(contains('splitTunnelMode: TunSplitTunnelMode.include'), contains('splitTunnelApps: [com.example.app]')),
      );
    });
  });
}
