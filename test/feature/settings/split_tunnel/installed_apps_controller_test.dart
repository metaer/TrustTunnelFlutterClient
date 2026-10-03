import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:trusttunnel/common/controller/controller/controller.dart';
import 'package:trusttunnel/data/model/installed_app.dart';
import 'package:trusttunnel/data/repository/installed_apps_repository.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/controller/installed_apps_controller.dart';

void main() {
  late _FakeInstalledAppsRepository repository;
  late InstalledAppsController controller;

  setUp(() {
    repository = _FakeInstalledAppsRepository();
    controller = InstalledAppsController(repository: repository);
  });

  tearDown(() => controller.dispose());

  test('starts without a loaded list', () {
    expect(controller.state.isLoaded, isFalse);
    expect(controller.state.apps, isEmpty);
  });

  test('fetch sorts the apps by label ignoring case', () async {
    repository.apps = const [
      InstalledApp(packageName: 'org.mozilla.firefox', label: 'firefox', isSystem: false),
      InstalledApp(packageName: 'com.android.chrome', label: 'Chrome', isSystem: true),
      InstalledApp(packageName: 'com.whatsapp', label: 'WhatsApp', isSystem: false),
    ];

    controller.fetch();
    await _settle(controller);

    expect(controller.state.apps.map((app) => app.label), ['Chrome', 'firefox', 'WhatsApp']);
    expect(controller.state.isLoaded, isTrue);
    expect(controller.state.loading, isFalse);
    expect(controller.state.error, isNull);
  });

  test('a failed fetch exposes the error and leaves the list not loaded', () async {
    repository.appsError = StateError('channel error');

    controller.fetch();
    await _settle(controller);

    expect(controller.state.error, isNotNull);
    expect(controller.state.isLoaded, isFalse);
    expect(controller.state.loading, isFalse);
    expect(controller.state.apps, isEmpty);
  });

  test('setQuery keeps a load error visible', () async {
    repository.appsError = StateError('channel error');
    controller.fetch();
    await _settle(controller);

    controller.setQuery('chr');
    await _settle(controller);

    expect(controller.state.query, 'chr');
    expect(controller.state.error, isNotNull);
    expect(controller.state.isLoaded, isFalse);
  });

  test('a retry after a failed fetch loads the list', () async {
    repository.appsError = StateError('channel error');
    controller.fetch();
    await _settle(controller);

    repository
      ..appsError = null
      ..apps = const [InstalledApp(packageName: 'com.android.chrome', label: 'Chrome', isSystem: true)];
    controller.fetch();
    await _settle(controller);

    expect(controller.state.error, isNull);
    expect(controller.state.isLoaded, isTrue);
    expect(controller.state.apps, hasLength(1));
  });

  test('setQuery keeps the loaded apps', () async {
    repository.apps = const [
      InstalledApp(packageName: 'com.android.chrome', label: 'Chrome', isSystem: true),
    ];
    controller.fetch();
    await _settle(controller);

    controller.setQuery('chr');
    await _settle(controller);

    expect(controller.state.query, 'chr');
    expect(controller.state.apps, hasLength(1));
  });

  test('iconOf requests every icon once', () async {
    final icon = Uint8List.fromList([1, 2, 3]);
    repository.icons['com.a'] = icon;

    final first = controller.iconOf('com.a');
    final second = controller.iconOf('com.a');

    expect(identical(first, second), isTrue);
    expect(await first, icon);
    expect(repository.iconRequests, ['com.a']);
  });

  test('iconOf retries an icon whose request failed', () async {
    repository.iconError = StateError('not installed');

    expect(await controller.iconOf('com.a'), isNull);

    repository.iconError = null;
    repository.icons['com.a'] = Uint8List.fromList([7]);

    expect(await controller.iconOf('com.a'), Uint8List.fromList([7]));
    expect(repository.iconRequests, ['com.a', 'com.a']);
  });

  test('toString does not print the apps', () async {
    repository.apps = const [
      InstalledApp(packageName: 'com.secret.app', label: 'Secret', isSystem: false),
    ];
    controller.fetch();
    await _settle(controller);

    expect(controller.state.toString(), isNot(contains('com.secret.app')));
    expect(controller.state.toString(), contains('appsCount: 1'));
  });
}

Future<void> _settle(Controller controller) async {
  do {
    await Future<void>.delayed(Duration.zero);
  } while (controller.isProcessing);
}

class _FakeInstalledAppsRepository implements InstalledAppsRepository {
  List<InstalledApp> apps = const [];
  Object? appsError;
  final Map<String, Uint8List> icons = {};
  Object? iconError;
  final List<String> iconRequests = [];

  @override
  Future<List<InstalledApp>> getInstalledApps() async {
    final error = appsError;
    if (error != null) throw error;

    return apps;
  }

  @override
  Future<Uint8List?> getAppIcon(String packageName) async {
    iconRequests.add(packageName);
    final error = iconError;
    if (error != null) throw error;

    return icons[packageName];
  }
}
