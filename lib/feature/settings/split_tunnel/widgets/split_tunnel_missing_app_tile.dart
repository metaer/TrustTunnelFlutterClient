import 'package:flutter/material.dart';
import 'package:trusttunnel/common/extensions/context_extensions.dart';
import 'package:trusttunnel/common/localization/localization.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/scope/split_tunnel_scope.dart';
import 'package:trusttunnel/widgets/common/custom_checkbox_list_tile.dart';

/// A selected package that is not installed anymore. Unchecking removes it
/// from the selection.
class SplitTunnelMissingAppTile extends StatelessWidget {
  final String packageName;

  const SplitTunnelMissingAppTile({
    super.key,
    required this.packageName,
  });

  @override
  Widget build(BuildContext context) => CustomCheckboxListTile(
    value: true,
    onChanged: (selected) => SplitTunnelScope.controllerOf(context, listen: false).setPackageSelected(
      packageName,
      selected: selected,
    ),
    title: Row(
      children: [
        const SizedBox.square(dimension: 40),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                packageName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.neutralLight,
                ),
              ),
              Text(
                context.ln.splitTunnelingAppNotInstalled,
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
