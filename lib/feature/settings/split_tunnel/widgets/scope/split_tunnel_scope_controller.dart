import 'dart:ui';

import 'package:trusttunnel/common/error/model/presentation_exception.dart';
import 'package:trusttunnel/data/model/split_tunnel_mode.dart';
import 'package:trusttunnel/data/model/split_tunnel_settings.dart';

typedef SplitTunnelPackageSelectedCallback = void Function(String packageName, {required bool selected});

abstract class SplitTunnelScopeController {
  /// Draft edited on the settings screen.
  abstract final SplitTunnelSettings settings;

  /// Persisted settings that the VPN is configured with.
  abstract final SplitTunnelSettings savedSettings;

  /// Whether [savedSettings] has been read from storage at least once.
  abstract final bool isLoaded;
  abstract final bool hasChanges;

  abstract final bool canSave;
  abstract final bool loading;

  abstract final PresentationException? error;

  abstract final void Function() fetch;
  abstract final void Function(SplitTunnelMode mode) changeMode;
  abstract final SplitTunnelPackageSelectedCallback setPackageSelected;
  abstract final void Function() resetDraft;

  abstract final void Function(VoidCallback onSaved) submit;
}
