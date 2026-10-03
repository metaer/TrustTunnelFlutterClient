import 'package:trusttunnel/common/error/model/presentation_exception.dart';
import 'package:trusttunnel/data/model/split_tunnel_mode.dart';
import 'package:trusttunnel/data/model/split_tunnel_settings.dart';

/// {@template split_tunnel_state}
/// State representation for split tunneling settings.
///
/// [settings] is the draft edited on the settings screen, [initialSettings] is
/// the persisted value that the VPN is configured with.
/// {@endtemplate}
sealed class SplitTunnelState {
  final SplitTunnelSettings settings;
  final SplitTunnelSettings initialSettings;

  /// Whether the persisted settings have been read at least once (successfully
  /// or not). Until then [initialSettings] is only a default value.
  final bool isLoaded;

  const SplitTunnelState._({
    required this.settings,
    required this.initialSettings,
    required this.isLoaded,
  });

  const factory SplitTunnelState.initial() = _InitialSplitTunnelState;

  /// Idle state
  const factory SplitTunnelState.idle({
    required SplitTunnelSettings settings,
    required SplitTunnelSettings initialSettings,
    required bool isLoaded,
  }) = _IdleSplitTunnelState;

  /// Loading state
  const factory SplitTunnelState.loading({
    required SplitTunnelSettings settings,
    required SplitTunnelSettings initialSettings,
    required bool isLoaded,
  }) = _LoadingSplitTunnelState;

  /// Error state
  const factory SplitTunnelState.exception({
    required SplitTunnelSettings settings,
    required SplitTunnelSettings initialSettings,
    required bool isLoaded,
    required PresentationException exception,
  }) = _ErrorSplitTunnelState;

  PresentationException? get error =>
      this is _ErrorSplitTunnelState ? (this as _ErrorSplitTunnelState).exception : null;

  bool get loading => this is _LoadingSplitTunnelState;

  /// Whether the draft routes apps differently from the persisted settings.
  ///
  /// The order of the selected apps does not matter, and neither does the
  /// hidden selection while routing is off.
  bool get hasChanges => !settings.isEquivalentTo(initialSettings);

  /// Whether the draft can be persisted. The "only selected apps" mode requires
  /// at least one selected app.
  bool get canSave => hasChanges && (settings.mode != SplitTunnelMode.include || settings.apps.isNotEmpty);

  @override
  String toString() =>
      'SplitTunnelState(type: $runtimeType, '
      'settings: $settings, initialSettings: $initialSettings, '
      'isLoaded: $isLoaded, loading: $loading)';
}

final class _IdleSplitTunnelState extends SplitTunnelState {
  const _IdleSplitTunnelState({
    required super.settings,
    required super.initialSettings,
    required super.isLoaded,
  }) : super._();
}

final class _InitialSplitTunnelState extends _IdleSplitTunnelState {
  const _InitialSplitTunnelState()
    : super(
        settings: const SplitTunnelSettings.off(),
        initialSettings: const SplitTunnelSettings.off(),
        isLoaded: false,
      );
}

final class _LoadingSplitTunnelState extends SplitTunnelState {
  const _LoadingSplitTunnelState({
    required super.settings,
    required super.initialSettings,
    required super.isLoaded,
  }) : super._();
}

final class _ErrorSplitTunnelState extends SplitTunnelState {
  final PresentationException exception;

  const _ErrorSplitTunnelState({
    required super.settings,
    required super.initialSettings,
    required super.isLoaded,
    required this.exception,
  }) : super._();
}
