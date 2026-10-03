import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/widgets/scope/installed_apps_scope.dart';

/// Launcher icon of an installed application, loaded lazily when the row is built.
class SplitTunnelAppIcon extends StatelessWidget {
  static const _size = 40.0;

  final String packageName;

  const SplitTunnelAppIcon({
    super.key,
    required this.packageName,
  });

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List?>(
    future: InstalledAppsScope.controllerOf(context, listen: false).iconOf(packageName),
    builder: (context, snapshot) {
      final bytes = snapshot.data;

      return bytes == null
          ? const SizedBox.square(dimension: _size)
          : Image.memory(
              bytes,
              width: _size,
              height: _size,
              gaplessPlayback: true,
            );
    },
  );
}
