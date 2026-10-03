import 'package:trusttunnel/common/error/model/presentation_exception.dart';
import 'package:trusttunnel/data/model/installed_app.dart';

/// {@template installed_apps_state}
/// State representation for the list of installed applications shown on the
/// split tunneling screen.
/// {@endtemplate}
sealed class InstalledAppsState {
  /// Installed applications sorted by label.
  final List<InstalledApp> apps;

  /// Search query applied to [apps].
  final String query;

  /// Whether [apps] has been loaded successfully at least once. Until then an
  /// empty [apps] does not mean that nothing is installed.
  final bool isLoaded;

  const InstalledAppsState._({
    required this.apps,
    required this.query,
    required this.isLoaded,
  });

  const factory InstalledAppsState.initial() = _InitialInstalledAppsState;

  /// Idle state
  const factory InstalledAppsState.idle({
    required List<InstalledApp> apps,
    required String query,
    required bool isLoaded,
  }) = _IdleInstalledAppsState;

  /// Loading state
  const factory InstalledAppsState.loading({
    required List<InstalledApp> apps,
    required String query,
    required bool isLoaded,
  }) = _LoadingInstalledAppsState;

  /// Error state
  const factory InstalledAppsState.exception({
    required List<InstalledApp> apps,
    required String query,
    required bool isLoaded,
    required PresentationException exception,
  }) = _ErrorInstalledAppsState;

  PresentationException? get error =>
      this is _ErrorInstalledAppsState ? (this as _ErrorInstalledAppsState).exception : null;

  bool get loading => this is _LoadingInstalledAppsState;

  // The app list and the query are deliberately not printed: states are logged.
  @override
  String toString() =>
      'InstalledAppsState(type: $runtimeType, '
      'appsCount: ${apps.length}, hasQuery: ${query.isNotEmpty}, isLoaded: $isLoaded, loading: $loading)';
}

final class _IdleInstalledAppsState extends InstalledAppsState {
  const _IdleInstalledAppsState({
    required super.apps,
    required super.query,
    required super.isLoaded,
  }) : super._();
}

final class _InitialInstalledAppsState extends _IdleInstalledAppsState {
  const _InitialInstalledAppsState()
    : super(
        apps: const [],
        query: '',
        isLoaded: false,
      );
}

final class _LoadingInstalledAppsState extends InstalledAppsState {
  const _LoadingInstalledAppsState({
    required super.apps,
    required super.query,
    required super.isLoaded,
  }) : super._();
}

final class _ErrorInstalledAppsState extends InstalledAppsState {
  final PresentationException exception;

  const _ErrorInstalledAppsState({
    required super.apps,
    required super.query,
    required super.isLoaded,
    required this.exception,
  }) : super._();
}
