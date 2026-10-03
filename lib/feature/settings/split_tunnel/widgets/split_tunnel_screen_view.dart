import 'package:flutter/material.dart';
import 'package:trusttunnel/common/extensions/context_extensions.dart';
import 'package:trusttunnel/common/localization/localization.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/scope/split_tunnel_aspect.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/scope/split_tunnel_scope.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/split_tunnel_body.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/split_tunnel_button_section.dart';
import 'package:trusttunnel/widgets/common/scaffold_messenger_provider.dart';
import 'package:trusttunnel/widgets/custom_app_bar.dart';
import 'package:trusttunnel/widgets/discard_changes_dialog.dart';
import 'package:trusttunnel/widgets/scaffold_wrapper.dart';

class SplitTunnelScreenView extends StatefulWidget {
  const SplitTunnelScreenView({
    super.key,
  });

  @override
  State<SplitTunnelScreenView> createState() => _SplitTunnelScreenViewState();
}

class _SplitTunnelScreenViewState extends State<SplitTunnelScreenView> {
  late bool hasChanges;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    hasChanges = SplitTunnelScope.controllerOf(
      context,
      aspect: SplitTunnelAspect.data,
    ).hasChanges;
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !hasChanges,
    onPopInvokedWithResult: (didPop, _) {
      if (didPop) {
        // The scope outlives the screen: drop discarded or hidden edits.
        SplitTunnelScope.controllerOf(context, listen: false).resetDraft();
      } else {
        _showNotSavedChangesWarning(context);
      }
    },
    child: ScaffoldWrapper(
      child: Scaffold(
        appBar: CustomAppBar(
          title: context.ln.splitTunneling,
        ),
        body: const Column(
          children: [
            Expanded(
              child: SplitTunnelBody(),
            ),
            SplitTunnelButtonSection(),
          ],
        ),
      ),
    ),
  );

  void _showNotSavedChangesWarning(BuildContext context) {
    final parentScaffoldMessenger = ScaffoldMessenger.maybeOf(context);

    showDialog(
      context: context,
      builder: (innerContext) => ScaffoldMessengerProvider(
        value: parentScaffoldMessenger ?? ScaffoldMessenger.of(innerContext),
        child: DiscardChangesDialog(
          onDiscardPressed: context.pop,
        ),
      ),
    );
  }
}
