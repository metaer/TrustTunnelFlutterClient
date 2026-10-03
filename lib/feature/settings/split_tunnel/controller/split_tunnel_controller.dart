import 'dart:ui';

import 'package:trusttunnel/common/controller/concurrency/sequential_controller_handler.dart';
import 'package:trusttunnel/common/controller/controller/state_controller.dart';
import 'package:trusttunnel/common/error/exception_utils.dart';
import 'package:trusttunnel/common/error/model/presentation_exception.dart';
import 'package:trusttunnel/data/model/split_tunnel_mode.dart';
import 'package:trusttunnel/data/model/split_tunnel_settings.dart';
import 'package:trusttunnel/data/repository/settings_repository.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/controller/split_tunnel_states.dart';

/// {@template split_tunnel_controller}
/// Controller for loading, editing and persisting split tunneling settings.
/// {@endtemplate}
final class SplitTunnelController extends BaseStateController<SplitTunnelState> with SequentialControllerHandler {
  final SettingsRepository _repository;

  /// {@macro split_tunnel_controller}
  SplitTunnelController({
    required SettingsRepository repository,
    super.initialState = const SplitTunnelState.initial(),
  }) : _repository = repository;

  /// Loads the persisted settings and resets the draft to them.
  ///
  /// A failed read still marks the settings as loaded, so the VPN can start
  /// with the default settings instead of waiting forever.
  void fetch() => handle(
    () async {
      setState(
        SplitTunnelState.loading(
          settings: state.settings,
          initialSettings: state.initialSettings,
          isLoaded: state.isLoaded,
        ),
      );

      final settings = await _repository.getSplitTunnelSettings();

      setState(
        SplitTunnelState.idle(
          settings: settings,
          initialSettings: settings,
          isLoaded: true,
        ),
      );
    },
    errorHandler: _onError,
    completionHandler: _onCompleted,
  );

  /// Changes the routing mode of the draft.
  void changeMode(SplitTunnelMode mode) => handle(
    () => _setDraft(state.settings.copyWith(mode: mode)),
    errorHandler: _onError,
    completionHandler: _onCompleted,
  );

  /// Adds [packageName] to or removes it from the draft's selected apps.
  ///
  /// The change is computed against the current state when the queued task
  /// runs, so rapid toggles never overwrite each other.
  void setPackageSelected(String packageName, {required bool selected}) => handle(
    () {
      final apps = state.settings.apps;
      if (apps.contains(packageName) == selected) return;

      _setDraft(
        state.settings.copyWith(
          apps: selected ? [...apps, packageName] : apps.where((app) => app != packageName).toList(growable: false),
        ),
      );
    },
    errorHandler: _onError,
    completionHandler: _onCompleted,
  );

  /// Drops unsaved changes by resetting the draft to the persisted settings.
  void resetDraft() => handle(
    () => _setDraft(state.initialSettings),
    errorHandler: _onError,
    completionHandler: _onCompleted,
  );

  /// Persists the draft and calls [onSaved] once it is stored.
  void submit(VoidCallback onSaved) => handle(
    () async {
      final settings = state.settings;

      setState(
        SplitTunnelState.loading(
          settings: settings,
          initialSettings: state.initialSettings,
          isLoaded: state.isLoaded,
        ),
      );

      await _repository.setSplitTunnelSettings(settings);

      setState(
        SplitTunnelState.idle(
          settings: settings,
          initialSettings: settings,
          isLoaded: true,
        ),
      );

      onSaved();
    },
    errorHandler: _onError,
    completionHandler: _onCompleted,
  );

  void _setDraft(SplitTunnelSettings settings) => setState(
    SplitTunnelState.idle(
      settings: settings,
      initialSettings: state.initialSettings,
      isLoaded: state.isLoaded,
    ),
  );

  PresentationException _parseException(Object? exception) =>
      ExceptionUtils.toPresentationException(exception: exception);

  Future<void> _onError(Object? error, StackTrace _) async => setState(
    SplitTunnelState.exception(
      exception: _parseException(error),
      settings: state.settings,
      initialSettings: state.initialSettings,
      isLoaded: true,
    ),
  );

  Future<void> _onCompleted() async {
    if (!state.loading) return;

    setState(
      SplitTunnelState.idle(
        settings: state.settings,
        initialSettings: state.initialSettings,
        isLoaded: state.isLoaded,
      ),
    );
  }
}
