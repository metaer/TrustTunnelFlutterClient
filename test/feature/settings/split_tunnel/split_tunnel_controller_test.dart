import 'package:flutter_test/flutter_test.dart';
import 'package:trusttunnel/common/controller/controller/controller.dart';
import 'package:trusttunnel/data/model/split_tunnel_mode.dart';
import 'package:trusttunnel/data/model/split_tunnel_settings.dart';
import 'package:trusttunnel/data/repository/settings_repository.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/controller/split_tunnel_controller.dart';

void main() {
  late _FakeSettingsRepository repository;
  late SplitTunnelController controller;

  setUp(() {
    repository = _FakeSettingsRepository();
    controller = SplitTunnelController(repository: repository);
  });

  tearDown(() => controller.dispose());

  Future<void> fetch(SplitTunnelSettings stored) async {
    repository.stored = stored;
    controller.fetch();
    await _settle(controller);
  }

  test('starts with off settings that are not loaded yet', () {
    expect(controller.state.isLoaded, isFalse);
    expect(controller.state.settings, const SplitTunnelSettings.off());
    expect(controller.state.initialSettings, const SplitTunnelSettings.off());
  });

  test('fetch loads the stored settings as both draft and saved settings', () async {
    const stored = SplitTunnelSettings(mode: SplitTunnelMode.include, apps: ['com.a']);

    await fetch(stored);

    expect(controller.state.isLoaded, isTrue);
    expect(controller.state.settings, stored);
    expect(controller.state.initialSettings, stored);
    expect(controller.state.hasChanges, isFalse);
    expect(controller.state.loading, isFalse);
  });

  test('a failed fetch still marks the settings as loaded', () async {
    repository.getError = StateError('database is closed');

    controller.fetch();
    await _settle(controller);

    expect(controller.state.isLoaded, isTrue);
    expect(controller.state.initialSettings, const SplitTunnelSettings.off());
    expect(controller.state.error, isNotNull);
  });

  test('changeMode edits only the draft', () async {
    await fetch(const SplitTunnelSettings.off());

    controller.changeMode(SplitTunnelMode.exclude);
    await _settle(controller);

    expect(controller.state.settings.mode, SplitTunnelMode.exclude);
    expect(controller.state.initialSettings, const SplitTunnelSettings.off());
    expect(controller.state.hasChanges, isTrue);
  });

  test('setPackageSelected adds and removes packages idempotently', () async {
    await fetch(const SplitTunnelSettings(mode: SplitTunnelMode.include, apps: []));

    controller
      ..setPackageSelected('com.a', selected: true)
      ..setPackageSelected('com.a', selected: true)
      ..setPackageSelected('com.b', selected: true);
    await _settle(controller);

    expect(controller.state.settings.apps, ['com.a', 'com.b']);

    controller
      ..setPackageSelected('com.a', selected: false)
      ..setPackageSelected('com.c', selected: false);
    await _settle(controller);

    expect(controller.state.settings.apps, ['com.b']);
  });

  test('rapid toggles are applied in order without losing updates', () async {
    await fetch(const SplitTunnelSettings(mode: SplitTunnelMode.exclude, apps: []));

    for (final packageName in ['com.a', 'com.b', 'com.c', 'com.d']) {
      controller.setPackageSelected(packageName, selected: true);
    }
    await _settle(controller);

    expect(controller.state.settings.apps, ['com.a', 'com.b', 'com.c', 'com.d']);
  });

  test('reselecting the same apps in another order is not a change', () async {
    await fetch(const SplitTunnelSettings(mode: SplitTunnelMode.include, apps: ['com.a', 'com.b']));

    controller
      ..setPackageSelected('com.a', selected: false)
      ..setPackageSelected('com.a', selected: true);
    await _settle(controller);

    expect(controller.state.settings.apps, ['com.b', 'com.a']);
    expect(controller.state.hasChanges, isFalse);
    expect(controller.state.canSave, isFalse);
  });

  test('a selection hidden by switching back to off is not a change', () async {
    await fetch(const SplitTunnelSettings(mode: SplitTunnelMode.off, apps: ['com.a']));

    controller
      ..changeMode(SplitTunnelMode.include)
      ..setPackageSelected('com.b', selected: true)
      ..changeMode(SplitTunnelMode.off);
    await _settle(controller);

    expect(controller.state.settings, const SplitTunnelSettings(mode: SplitTunnelMode.off, apps: ['com.a', 'com.b']));
    expect(controller.state.hasChanges, isFalse);
    expect(controller.state.canSave, isFalse);
  });

  test('resetDraft drops unsaved changes', () async {
    const stored = SplitTunnelSettings(mode: SplitTunnelMode.exclude, apps: ['com.a']);
    await fetch(stored);

    controller
      ..changeMode(SplitTunnelMode.include)
      ..setPackageSelected('com.b', selected: true)
      ..resetDraft();
    await _settle(controller);

    expect(controller.state.settings, stored);
    expect(controller.state.initialSettings, stored);
    expect(controller.state.hasChanges, isFalse);
    expect(repository.setCalls, 0);
  });

  test('canSave requires a change and at least one app in include mode', () async {
    await fetch(const SplitTunnelSettings.off());
    expect(controller.state.canSave, isFalse);

    controller.changeMode(SplitTunnelMode.include);
    await _settle(controller);
    expect(controller.state.canSave, isFalse);

    controller.setPackageSelected('com.a', selected: true);
    await _settle(controller);
    expect(controller.state.canSave, isTrue);

    controller
      ..setPackageSelected('com.a', selected: false)
      ..changeMode(SplitTunnelMode.exclude);
    await _settle(controller);
    expect(controller.state.canSave, isTrue);
  });

  test('submit persists the draft and calls onSaved once', () async {
    await fetch(const SplitTunnelSettings.off());
    var savedCalls = 0;

    controller
      ..changeMode(SplitTunnelMode.include)
      ..setPackageSelected('com.a', selected: true)
      ..submit(() => savedCalls++);
    await _settle(controller);

    const expected = SplitTunnelSettings(mode: SplitTunnelMode.include, apps: ['com.a']);
    expect(repository.stored, expected);
    expect(repository.setCalls, 1);
    expect(savedCalls, 1);
    expect(controller.state.initialSettings, expected);
    expect(controller.state.settings, expected);
    expect(controller.state.hasChanges, isFalse);
    expect(controller.state.loading, isFalse);
  });

  test('a failed submit keeps the draft and does not call onSaved', () async {
    await fetch(const SplitTunnelSettings.off());
    repository.setError = StateError('disk full');
    var savedCalls = 0;

    controller
      ..changeMode(SplitTunnelMode.exclude)
      ..submit(() => savedCalls++);
    await _settle(controller);

    expect(savedCalls, 0);
    expect(controller.state.settings.mode, SplitTunnelMode.exclude);
    expect(controller.state.initialSettings, const SplitTunnelSettings.off());
    expect(controller.state.error, isNotNull);
    expect(controller.state.loading, isFalse);
  });

  test('toString keeps the selected apps under the sanitized key', () async {
    await fetch(const SplitTunnelSettings(mode: SplitTunnelMode.include, apps: ['com.a']));

    expect(controller.state.toString(), contains('splitTunnelApps: [com.a]'));
  });
}

Future<void> _settle(Controller controller) async {
  do {
    await Future<void>.delayed(Duration.zero);
  } while (controller.isProcessing);
}

class _FakeSettingsRepository implements SettingsRepository {
  SplitTunnelSettings stored = const SplitTunnelSettings.off();
  Object? getError;
  Object? setError;
  int setCalls = 0;

  @override
  Future<SplitTunnelSettings> getSplitTunnelSettings() async {
    final error = getError;
    if (error != null) throw error;

    return stored;
  }

  @override
  Future<void> setSplitTunnelSettings(SplitTunnelSettings settings) async {
    final error = setError;
    if (error != null) throw error;

    setCalls++;
    stored = settings;
  }

  @override
  Future<List<String>> getExcludedRoutes() async => const [];

  @override
  Future<void> setExcludedRoutes(List<String> routes) async {}
}
