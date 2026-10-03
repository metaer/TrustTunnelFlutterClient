import 'package:flutter/material.dart';
import 'package:trusttunnel/common/extensions/context_extensions.dart';
import 'package:trusttunnel/common/localization/localization.dart';
import 'package:trusttunnel/data/model/split_tunnel_mode.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/scope/split_tunnel_aspect.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/scope/split_tunnel_scope.dart';
import 'package:trusttunnel/widgets/common/custom_radio_list_tile.dart';

class SplitTunnelModeSelector extends StatefulWidget {
  const SplitTunnelModeSelector({super.key});

  @override
  State<SplitTunnelModeSelector> createState() => _SplitTunnelModeSelectorState();
}

class _SplitTunnelModeSelectorState extends State<SplitTunnelModeSelector> {
  late SplitTunnelMode _mode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mode = SplitTunnelScope.controllerOf(
      context,
      aspect: SplitTunnelAspect.data,
    ).settings.mode;
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          context.ln.splitTunnelingDescription,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.neutralLight,
          ),
        ),
      ),
      CustomRadioListTile<SplitTunnelMode>(
        value: SplitTunnelMode.off,
        groupValue: _mode,
        onChanged: _changeMode,
        title: context.ln.splitTunnelingModeOff,
        subTitle: context.ln.splitTunnelingModeOffDescription,
        radioColor: context.colors.neutralBlack,
      ),
      CustomRadioListTile<SplitTunnelMode>(
        value: SplitTunnelMode.include,
        groupValue: _mode,
        onChanged: _changeMode,
        title: context.ln.splitTunnelingModeInclude,
        subTitle: context.ln.splitTunnelingModeIncludeDescription,
        radioColor: context.colors.neutralBlack,
      ),
      CustomRadioListTile<SplitTunnelMode>(
        value: SplitTunnelMode.exclude,
        groupValue: _mode,
        onChanged: _changeMode,
        title: context.ln.splitTunnelingModeExclude,
        subTitle: context.ln.splitTunnelingModeExcludeDescription,
        radioColor: context.colors.neutralBlack,
      ),
    ],
  );

  void _changeMode(SplitTunnelMode? mode) {
    if (mode == null) return;

    SplitTunnelScope.controllerOf(context, listen: false).changeMode(mode);
  }
}
