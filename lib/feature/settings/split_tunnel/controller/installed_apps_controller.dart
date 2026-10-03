import 'dart:typed_data';

import 'package:trusttunnel/common/controller/concurrency/sequential_controller_handler.dart';
import 'package:trusttunnel/common/controller/controller/state_controller.dart';
import 'package:trusttunnel/common/error/exception_utils.dart';
import 'package:trusttunnel/common/error/model/presentation_exception.dart';
import 'package:trusttunnel/data/repository/installed_apps_repository.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/controller/installed_apps_states.dart';

/// {@template installed_apps_controller}
/// Controller for the installed applications shown on the split tunneling
/// screen: loads them, keeps the search query and caches their icons.
/// {@endtemplate}
final class InstalledAppsController extends BaseStateController<InstalledAppsState> with SequentialControllerHandler {
  final InstalledAppsRepository _repository;

  /// Icon requests by package name. Kept outside of the state to avoid
  /// rebuilding the list whenever an icon arrives.
  final Map<String, Future<Uint8List?>> _icons = {};

  /// {@macro installed_apps_controller}
  InstalledAppsController({
    required InstalledAppsRepository repository,
    super.initialState = const InstalledAppsState.initial(),
  }) : _repository = repository;

  /// Loads the installed applications sorted by label.
  void fetch() => handle(
    () async {
      setState(
        InstalledAppsState.loading(
          apps: state.apps,
          query: state.query,
          isLoaded: state.isLoaded,
        ),
      );

      final apps = [...await _repository.getInstalledApps()]
        ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));

      setState(
        InstalledAppsState.idle(
          apps: List.unmodifiable(apps),
          query: state.query,
          isLoaded: true,
        ),
      );
    },
    errorHandler: _onError,
    completionHandler: _onCompleted,
  );

  /// Changes the search query. A load error stays visible.
  void setQuery(String query) => handle(
    () {
      final error = state.error;

      setState(
        error == null
            ? InstalledAppsState.idle(
                apps: state.apps,
                query: query,
                isLoaded: state.isLoaded,
              )
            : InstalledAppsState.exception(
                exception: error,
                apps: state.apps,
                query: query,
                isLoaded: state.isLoaded,
              ),
      );
    },
    errorHandler: _onError,
    completionHandler: _onCompleted,
  );

  /// Returns the launcher icon of [packageName] as PNG bytes.
  ///
  /// Requests are cached for the lifetime of the controller; a failed request
  /// is evicted so that it is retried the next time the icon is shown.
  Future<Uint8List?> iconOf(String packageName) => _icons.putIfAbsent(
    packageName,
    () => _loadIcon(packageName),
  );

  Future<Uint8List?> _loadIcon(String packageName) async {
    try {
      return await _repository.getAppIcon(packageName);
    } on Object {
      _icons.remove(packageName);

      return null;
    }
  }

  PresentationException _parseException(Object? exception) =>
      ExceptionUtils.toPresentationException(exception: exception);

  Future<void> _onError(Object? error, StackTrace _) async => setState(
    InstalledAppsState.exception(
      exception: _parseException(error),
      apps: state.apps,
      query: state.query,
      isLoaded: state.isLoaded,
    ),
  );

  Future<void> _onCompleted() async {
    if (!state.loading) return;

    setState(
      InstalledAppsState.idle(
        apps: state.apps,
        query: state.query,
        isLoaded: state.isLoaded,
      ),
    );
  }
}
