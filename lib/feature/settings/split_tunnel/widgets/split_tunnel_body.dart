import 'package:flutter/material.dart';
import 'package:trusttunnel/common/extensions/context_extensions.dart';
import 'package:trusttunnel/common/localization/localization.dart';
import 'package:trusttunnel/data/model/installed_app.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/domain/installed_apps_filter.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/scope/installed_apps_aspect.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/scope/installed_apps_scope.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/scope/split_tunnel_aspect.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/scope/split_tunnel_scope.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/split_tunnel_app_tile.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/split_tunnel_apps_filter.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/split_tunnel_missing_app_tile.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/split_tunnel_mode_selector.dart';

class SplitTunnelBody extends StatefulWidget {
  const SplitTunnelBody({super.key});

  @override
  State<SplitTunnelBody> createState() => _SplitTunnelBodyState();
}

class _SplitTunnelBodyState extends State<SplitTunnelBody> {
  late bool _isEnabled;
  late List<String> _selectedApps;
  late List<String> _savedApps;
  late List<InstalledApp> _apps;
  late String _query;
  late bool _appsLoaded;
  late bool _hasError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final splitTunnelController = SplitTunnelScope.controllerOf(
      context,
      aspect: SplitTunnelAspect.data,
    );
    _isEnabled = splitTunnelController.settings.isEnabled;
    _selectedApps = splitTunnelController.settings.apps;
    _savedApps = splitTunnelController.savedSettings.apps;

    final appsController = InstalledAppsScope.controllerOf(
      context,
      aspect: InstalledAppsAspect.apps,
    );
    _apps = appsController.apps;
    _appsLoaded = appsController.isLoaded;
    _hasError = appsController.error != null;
    _query = InstalledAppsScope.controllerOf(
      context,
      aspect: InstalledAppsAspect.query,
    ).query;
  }

  @override
  Widget build(BuildContext context) {
    // Apps saved before the screen was opened stay on top; the order does not
    // change while the selection is being edited.
    final visibleApps = InstalledAppsFilter.visible(
      apps: _apps,
      query: _query,
      pinned: _savedApps.toSet(),
    );
    // Until the list is loaded, every selected app would look uninstalled.
    final missingApps = _appsLoaded
        ? InstalledAppsFilter.missing(
            apps: _apps,
            selected: _selectedApps,
            query: _query,
          )
        : const <String>[];
    final selectedApps = _selectedApps.toSet();

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: SplitTunnelModeSelector(),
        ),
        if (_isEnabled) ...[
          const SliverToBoxAdapter(
            child: Divider(),
          ),
          const SliverToBoxAdapter(
            child: SplitTunnelAppsFilter(),
          ),
          if (!_appsLoaded && _hasError)
            SliverToBoxAdapter(
              child: _AppsLoadErrorSection(
                onRetry: InstalledAppsScope.controllerOf(context, listen: false).fetch,
              ),
            )
          else if (!_appsLoaded)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            )
          else ...[
            SliverList.builder(
              itemCount: missingApps.length,
              itemBuilder: (context, index) => SplitTunnelMissingAppTile(
                key: ValueKey(missingApps[index]),
                packageName: missingApps[index],
              ),
            ),
            SliverList.builder(
              itemCount: visibleApps.length,
              itemBuilder: (context, index) {
                final app = visibleApps[index];

                return SplitTunnelAppTile(
                  key: ValueKey(app.packageName),
                  app: app,
                  selected: selectedApps.contains(app.packageName),
                );
              },
            ),
            if (visibleApps.isEmpty && missingApps.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    context.ln.splitTunnelingNoAppsFound,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.neutralLight,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ],
    );
  }
}

class _AppsLoadErrorSection extends StatelessWidget {
  final VoidCallback onRetry;

  const _AppsLoadErrorSection({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Text(
          context.ln.splitTunnelingAppsLoadError,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.error,
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onRetry,
          child: Text(context.ln.splitTunnelingRetry),
        ),
      ],
    ),
  );
}
