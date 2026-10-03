import 'package:flutter/material.dart';
import 'package:trusttunnel/common/extensions/context_extensions.dart';
import 'package:trusttunnel/common/localization/localization.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/scope/installed_apps_scope.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/scope/split_tunnel_aspect.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/scope/split_tunnel_scope.dart';
import 'package:trusttunnel/widgets/inputs/custom_text_field.dart';

/// Search field and selection counter above the split tunneling app list.
class SplitTunnelAppsFilter extends StatefulWidget {
  const SplitTunnelAppsFilter({super.key});

  @override
  State<SplitTunnelAppsFilter> createState() => _SplitTunnelAppsFilterState();
}

class _SplitTunnelAppsFilterState extends State<SplitTunnelAppsFilter> {
  // Owned here so that the field never shows a query the controller has not
  // processed yet; the controller only receives it for filtering.
  late String _query;
  late int _selectedCount;

  @override
  void initState() {
    super.initState();
    _query = InstalledAppsScope.controllerOf(context, listen: false).query;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedCount = SplitTunnelScope.controllerOf(
      context,
      aspect: SplitTunnelAspect.data,
    ).settings.apps.length;
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          value: _query,
          hint: context.ln.splitTunnelingSearchApps,
          onChanged: _onQueryChanged,
        ),
        const SizedBox(height: 16),
        Text(
          context.ln.splitTunnelingSelectedApps(_selectedCount),
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.neutralLight,
          ),
        ),
      ],
    ),
  );

  void _onQueryChanged(String query) {
    setState(() => _query = query);
    InstalledAppsScope.controllerOf(context, listen: false).setQuery(query);
  }
}
