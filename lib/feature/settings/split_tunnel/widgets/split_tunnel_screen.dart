import 'package:flutter/material.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/scope/installed_apps_scope.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/scope/split_tunnel_scope.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/split_tunnel_screen_view.dart';

/// Split tunneling settings screen. Must be pushed inside an [InstalledAppsScope].
class SplitTunnelScreen extends StatefulWidget {
  const SplitTunnelScreen({super.key});

  @override
  State<SplitTunnelScreen> createState() => _SplitTunnelScreenState();
}

class _SplitTunnelScreenState extends State<SplitTunnelScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SplitTunnelScope.controllerOf(context, listen: false).fetch();
      InstalledAppsScope.controllerOf(context, listen: false).fetch();
    });
  }

  @override
  Widget build(BuildContext context) => const SplitTunnelScreenView();
}
