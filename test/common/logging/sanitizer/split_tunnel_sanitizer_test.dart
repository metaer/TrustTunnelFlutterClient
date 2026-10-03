import 'package:flutter_test/flutter_test.dart';
import 'package:trusttunnel/common/logging/enum/logging_security_type.dart';
import 'package:trusttunnel/common/logging/sanitizer/trust_tunnel_sensitive_data_sanitizer.dart';
import 'package:trusttunnel/data/model/split_tunnel_mode.dart';
import 'package:trusttunnel/data/model/split_tunnel_settings.dart';

void main() {
  const sanitizer = TrustTunnelSensitiveDataSanitizer();

  group('split tunneling apps in stripped logs', () {
    test('are reduced to a presence placeholder in payloads', () {
      expect(
        sanitizer.sanitizePayload(<String, Object?>{
          'splitTunnelMode': 'include',
          'splitTunnelApps': ['com.android.chrome'],
        }, LoggingSecurityType.stripped),
        {'splitTunnelMode': 'include', 'splitTunnelApps': 'filled'},
      );
      expect(
        sanitizer.sanitizePayload(<String, Object?>{'splitTunnelApps': <String>[]}, LoggingSecurityType.stripped),
        {'splitTunnelApps': 'empty'},
      );
    });

    test('are hidden in logged state descriptions', () {
      final text = sanitizer.sanitizePayload(
        const SplitTunnelSettings(
          mode: SplitTunnelMode.include,
          apps: ['com.android.chrome', 'org.mozilla.firefox'],
        ).toString(),
        LoggingSecurityType.stripped,
      );

      expect(text, isNot(contains('com.android.chrome')));
      expect(text, isNot(contains('org.mozilla.firefox')));
      expect(text, contains('SplitTunnelMode.include'));
    });
  });

  test('split tunneling apps are kept in full logs', () {
    expect(
      sanitizer.sanitizePayload(<String, Object?>{
        'splitTunnelApps': ['com.android.chrome'],
      }, LoggingSecurityType.full),
      {
        'splitTunnelApps': ['com.android.chrome'],
      },
    );
  });
}
