import 'package:flutter/material.dart';
import 'package:trusttunnel/common/extensions/context_extensions.dart';
import 'package:trusttunnel/common/localization/localization.dart';
import 'package:trusttunnel/data/model/split_tunnel_mode.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/scope/split_tunnel_aspect.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/scope/split_tunnel_scope.dart';

class SplitTunnelButtonSection extends StatefulWidget {
  const SplitTunnelButtonSection({
    super.key,
  });

  @override
  State<SplitTunnelButtonSection> createState() => _SplitTunnelButtonSectionState();
}

class _SplitTunnelButtonSectionState extends State<SplitTunnelButtonSection> {
  late bool _canSave;
  late bool _needsApps;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = SplitTunnelScope.controllerOf(context, aspect: SplitTunnelAspect.data);
    _canSave = controller.canSave;
    _needsApps = controller.settings.mode == SplitTunnelMode.include && controller.settings.apps.isEmpty;
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: context.isMobileBreakpoint ? CrossAxisAlignment.stretch : CrossAxisAlignment.end,
    children: [
      const Divider(),
      if (_needsApps)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            context.ln.splitTunnelingSelectAtLeastOneApp,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.neutralLight,
            ),
          ),
        ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _canSave ? () => _saveSettings(context) : null,
          child: Text(context.ln.save),
        ),
      ),
    ],
  );

  void _saveSettings(BuildContext context) =>
      SplitTunnelScope.controllerOf(context, listen: false).submit(() => _onSettingsSaved(context));

  void _onSettingsSaved(BuildContext context) {
    if (Navigator.canPop(context)) {
      context.pop();
    }
  }
}
