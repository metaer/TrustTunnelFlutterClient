import 'package:flutter_test/flutter_test.dart';
import 'package:trusttunnel/data/model/split_tunnel_mode.dart';
import 'package:trusttunnel/data/model/split_tunnel_settings.dart';

void main() {
  group('SplitTunnelMode.parse', () {
    test('parses every stored value', () {
      for (final mode in SplitTunnelMode.values) {
        expect(SplitTunnelMode.parse(mode.value), mode);
      }
    });

    test('falls back to off for null and unknown values', () {
      expect(SplitTunnelMode.parse(null), SplitTunnelMode.off);
      expect(SplitTunnelMode.parse('everything'), SplitTunnelMode.off);
    });
  });

  group('SplitTunnelSettings', () {
    test('off routes every app through the VPN', () {
      const settings = SplitTunnelSettings.off();

      expect(settings.mode, SplitTunnelMode.off);
      expect(settings.apps, isEmpty);
      expect(settings.isEnabled, isFalse);
    });

    test('is enabled for include and exclude', () {
      expect(const SplitTunnelSettings(mode: SplitTunnelMode.include, apps: []).isEnabled, isTrue);
      expect(const SplitTunnelSettings(mode: SplitTunnelMode.exclude, apps: []).isEnabled, isTrue);
    });

    test('uses value equality', () {
      // Distinct, non-canonicalized instances.
      final a = SplitTunnelSettings(mode: SplitTunnelMode.include, apps: ['com.a', 'com.b'].toList());
      final b = SplitTunnelSettings(mode: SplitTunnelMode.include, apps: ['com.a', 'com.b'].toList());

      expect(identical(a, b), isFalse);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(const SplitTunnelSettings(mode: SplitTunnelMode.exclude, apps: ['com.a', 'com.b'])));
      expect(a, isNot(const SplitTunnelSettings(mode: SplitTunnelMode.include, apps: ['com.b', 'com.a'])));
    });

    test('copyWith replaces only the given fields', () {
      const settings = SplitTunnelSettings(mode: SplitTunnelMode.include, apps: ['com.a']);

      expect(
        settings.copyWith(mode: SplitTunnelMode.exclude),
        const SplitTunnelSettings(mode: SplitTunnelMode.exclude, apps: ['com.a']),
      );
      expect(
        settings.copyWith(apps: ['com.b']),
        const SplitTunnelSettings(mode: SplitTunnelMode.include, apps: ['com.b']),
      );
      expect(settings.copyWith(), settings);
    });

    test('isEquivalentTo ignores the order of the apps', () {
      expect(
        const SplitTunnelSettings(
          mode: SplitTunnelMode.include,
          apps: ['com.a', 'com.b'],
        ).isEquivalentTo(const SplitTunnelSettings(mode: SplitTunnelMode.include, apps: ['com.b', 'com.a'])),
        isTrue,
      );
      expect(
        const SplitTunnelSettings(
          mode: SplitTunnelMode.exclude,
          apps: ['com.a'],
        ).isEquivalentTo(const SplitTunnelSettings(mode: SplitTunnelMode.exclude, apps: ['com.a', 'com.b'])),
        isFalse,
      );
    });

    test('isEquivalentTo ignores the apps only while routing is off', () {
      expect(
        const SplitTunnelSettings(
          mode: SplitTunnelMode.off,
          apps: ['com.a'],
        ).isEquivalentTo(const SplitTunnelSettings.off()),
        isTrue,
      );
      expect(
        const SplitTunnelSettings(
          mode: SplitTunnelMode.include,
          apps: ['com.a'],
        ).isEquivalentTo(const SplitTunnelSettings(mode: SplitTunnelMode.off, apps: ['com.a'])),
        isFalse,
      );
    });

    test('prints the apps under the sanitized splitTunnelApps key', () {
      expect(
        const SplitTunnelSettings(mode: SplitTunnelMode.include, apps: ['com.a']).toString(),
        contains('splitTunnelApps: [com.a]'),
      );
    });
  });
}
