import 'package:flutter/widgets.dart';
import 'package:trusttunnel/common/controller/widget/state_consumer.dart';
import 'package:trusttunnel/common/error/model/presentation_exception.dart';
import 'package:trusttunnel/common/extensions/context_extensions.dart';
import 'package:trusttunnel/data/model/split_tunnel_mode.dart';
import 'package:trusttunnel/data/model/split_tunnel_settings.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/controller/split_tunnel_controller.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/controller/split_tunnel_states.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/scope/split_tunnel_aspect.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/scope/split_tunnel_scope_controller.dart';

class SplitTunnelScope extends StatefulWidget {
  final Widget child;

  const SplitTunnelScope({
    required this.child,
    super.key,
  });

  static SplitTunnelScopeController controllerOf(
    BuildContext context, {
    bool listen = true,
    SplitTunnelAspect? aspect,
  }) => _InheritedSplitTunnelScope.controllerOf(context, listen: listen, aspect: aspect);

  @override
  State<SplitTunnelScope> createState() => _SplitTunnelScopeState();
}

class _SplitTunnelScopeState extends State<SplitTunnelScope> {
  late final SplitTunnelController _controller;

  @override
  void initState() {
    super.initState();
    final repositoryFactory = context.repositoryFactory;

    _controller = SplitTunnelController(
      repository: repositoryFactory.settingsRepository,
    );

    _controller.fetch();
  }

  @override
  Widget build(BuildContext context) => StateConsumer<SplitTunnelController, SplitTunnelState>(
    controller: _controller,
    builder: (context, state, _) => _InheritedSplitTunnelScope(
      state: state,
      fetch: _controller.fetch,
      changeMode: _controller.changeMode,
      setPackageSelected: _controller.setPackageSelected,
      resetDraft: _controller.resetDraft,
      submit: _controller.submit,
      child: widget.child,
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _InheritedSplitTunnelScope extends InheritedModel<SplitTunnelAspect> implements SplitTunnelScopeController {
  final SplitTunnelState _state;

  const _InheritedSplitTunnelScope({
    required SplitTunnelState state,
    required this.fetch,
    required this.changeMode,
    required this.setPackageSelected,
    required this.resetDraft,
    required this.submit,
    required super.child,
  }) : _state = state;

  @override
  final void Function() fetch;

  @override
  final void Function(SplitTunnelMode mode) changeMode;

  @override
  final SplitTunnelPackageSelectedCallback setPackageSelected;

  @override
  final void Function() resetDraft;

  @override
  final void Function(VoidCallback onSaved) submit;

  @override
  SplitTunnelSettings get settings => _state.settings;

  @override
  SplitTunnelSettings get savedSettings => _state.initialSettings;

  @override
  bool get isLoaded => _state.isLoaded;

  @override
  PresentationException? get error => _state.error;

  @override
  bool get loading => _state.loading;

  @override
  bool get hasChanges => _state.hasChanges;

  @override
  bool get canSave => _state.canSave;

  @override
  bool updateShouldNotify(_InheritedSplitTunnelScope oldWidget) => _state != oldWidget._state;

  static _InheritedSplitTunnelScope controllerOf(
    BuildContext context, {
    bool listen = true,
    SplitTunnelAspect? aspect,
  }) => _scope(context, listen: listen, aspect: aspect) ?? _notFoundInheritedWidgetOfExactType();

  @override
  bool updateShouldNotifyDependent(
    covariant _InheritedSplitTunnelScope oldWidget,
    Set<SplitTunnelAspect> dependencies,
  ) {
    if (dependencies.isEmpty) return updateShouldNotify(oldWidget);

    bool hasAnyChanges = false;

    for (final aspect in dependencies) {
      hasAnyChanges |= switch (aspect) {
        SplitTunnelAspect.loading => loading != oldWidget.loading,
        SplitTunnelAspect.settings => savedSettings != oldWidget.savedSettings || isLoaded != oldWidget.isLoaded,
        SplitTunnelAspect.data =>
          settings != oldWidget.settings ||
              savedSettings != oldWidget.savedSettings ||
              isLoaded != oldWidget.isLoaded ||
              error != oldWidget.error,
      };

      if (hasAnyChanges) return true;
    }

    return false;
  }

  static _InheritedSplitTunnelScope? _scope(
    BuildContext context, {
    bool listen = true,
    SplitTunnelAspect? aspect,
  }) => (listen
      ? InheritedModel.inheritFrom<_InheritedSplitTunnelScope>(
          context,
          aspect: aspect,
        )
      : context.getElementForInheritedWidgetOfExactType<_InheritedSplitTunnelScope>()?.widget
            as _InheritedSplitTunnelScope?);

  static Never _notFoundInheritedWidgetOfExactType<T extends InheritedModel<SplitTunnelAspect>>() =>
      throw ArgumentError(
        'Inherited widget out of scope and not found of $T exact type',
        'out_of_scope',
      );
}
