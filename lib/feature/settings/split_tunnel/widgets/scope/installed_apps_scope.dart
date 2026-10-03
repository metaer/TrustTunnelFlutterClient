import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:trusttunnel/common/controller/widget/state_consumer.dart';
import 'package:trusttunnel/common/error/model/presentation_exception.dart';
import 'package:trusttunnel/common/extensions/context_extensions.dart';
import 'package:trusttunnel/data/model/installed_app.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/controller/installed_apps_controller.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/controller/installed_apps_states.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/scope/installed_apps_aspect.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/scope/installed_apps_scope_controller.dart';

/// Screen-level scope with the installed applications for the split tunneling
/// screen. It is created together with the screen, so the application list and
/// the icon cache are released when the screen is closed.
class InstalledAppsScope extends StatefulWidget {
  final Widget child;

  const InstalledAppsScope({
    required this.child,
    super.key,
  });

  static InstalledAppsScopeController controllerOf(
    BuildContext context, {
    bool listen = true,
    InstalledAppsAspect? aspect,
  }) => _InheritedInstalledAppsScope.controllerOf(context, listen: listen, aspect: aspect);

  @override
  State<InstalledAppsScope> createState() => _InstalledAppsScopeState();
}

class _InstalledAppsScopeState extends State<InstalledAppsScope> {
  late final InstalledAppsController _controller;

  @override
  void initState() {
    super.initState();
    final repositoryFactory = context.repositoryFactory;

    _controller = InstalledAppsController(
      repository: repositoryFactory.installedAppsRepository,
    );
  }

  @override
  Widget build(BuildContext context) => StateConsumer<InstalledAppsController, InstalledAppsState>(
    controller: _controller,
    builder: (context, state, _) => _InheritedInstalledAppsScope(
      state: state,
      fetch: _controller.fetch,
      setQuery: _controller.setQuery,
      iconOf: _controller.iconOf,
      child: widget.child,
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _InheritedInstalledAppsScope extends InheritedModel<InstalledAppsAspect> implements InstalledAppsScopeController {
  final InstalledAppsState _state;

  const _InheritedInstalledAppsScope({
    required InstalledAppsState state,
    required this.fetch,
    required this.setQuery,
    required this.iconOf,
    required super.child,
  }) : _state = state;

  @override
  final void Function() fetch;

  @override
  final void Function(String query) setQuery;

  @override
  final Future<Uint8List?> Function(String packageName) iconOf;

  @override
  List<InstalledApp> get apps => _state.apps;

  @override
  String get query => _state.query;

  @override
  bool get isLoaded => _state.isLoaded;

  @override
  PresentationException? get error => _state.error;

  @override
  bool get loading => _state.loading;

  @override
  bool updateShouldNotify(_InheritedInstalledAppsScope oldWidget) => _state != oldWidget._state;

  static _InheritedInstalledAppsScope controllerOf(
    BuildContext context, {
    bool listen = true,
    InstalledAppsAspect? aspect,
  }) => _scope(context, listen: listen, aspect: aspect) ?? _notFoundInheritedWidgetOfExactType();

  @override
  bool updateShouldNotifyDependent(
    covariant _InheritedInstalledAppsScope oldWidget,
    Set<InstalledAppsAspect> dependencies,
  ) {
    if (dependencies.isEmpty) return updateShouldNotify(oldWidget);

    bool hasAnyChanges = false;

    for (final aspect in dependencies) {
      hasAnyChanges |= switch (aspect) {
        InstalledAppsAspect.apps =>
          !listEquals(apps, oldWidget.apps) ||
              isLoaded != oldWidget.isLoaded ||
              loading != oldWidget.loading ||
              error != oldWidget.error,
        InstalledAppsAspect.query => query != oldWidget.query,
      };

      if (hasAnyChanges) return true;
    }

    return false;
  }

  static _InheritedInstalledAppsScope? _scope(
    BuildContext context, {
    bool listen = true,
    InstalledAppsAspect? aspect,
  }) => (listen
      ? InheritedModel.inheritFrom<_InheritedInstalledAppsScope>(
          context,
          aspect: aspect,
        )
      : context.getElementForInheritedWidgetOfExactType<_InheritedInstalledAppsScope>()?.widget
            as _InheritedInstalledAppsScope?);

  static Never _notFoundInheritedWidgetOfExactType<T extends InheritedModel<InstalledAppsAspect>>() =>
      throw ArgumentError(
        'Inherited widget out of scope and not found of $T exact type',
        'out_of_scope',
      );
}
