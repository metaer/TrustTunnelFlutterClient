import 'package:flutter/material.dart';
import 'package:trusttunnel/common/extensions/context_extensions.dart';
import 'package:trusttunnel/data/model/installed_app.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/scope/split_tunnel_scope.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/split_tunnel_app_icon.dart';
import 'package:trusttunnel/widgets/common/custom_checkbox_list_tile.dart';

class SplitTunnelAppTile extends StatelessWidget {
  final InstalledApp app;
  final bool selected;

  const SplitTunnelAppTile({
    super.key,
    required this.app,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) => CustomCheckboxListTile(
    value: selected,
    onChanged: (selected) => SplitTunnelScope.controllerOf(context, listen: false).setPackageSelected(
      app.packageName,
      selected: selected,
    ),
    title: Row(
      children: [
        SplitTunnelAppIcon(
          packageName: app.packageName,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                app.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyLarge,
              ),
              Text(
                app.packageName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.neutralLight,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
