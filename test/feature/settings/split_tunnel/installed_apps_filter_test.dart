import 'package:flutter_test/flutter_test.dart';
import 'package:trusttunnel/data/model/installed_app.dart';
import 'package:trusttunnel/feature/settings/split_tunnel/domain/installed_apps_filter.dart';

void main() {
  const chrome = InstalledApp(packageName: 'com.android.chrome', label: 'Chrome', isSystem: true);
  const firefox = InstalledApp(packageName: 'org.mozilla.firefox', label: 'Firefox', isSystem: false);
  const youtube = InstalledApp(packageName: 'com.google.android.youtube', label: 'YouTube', isSystem: true);
  const apps = [chrome, firefox, youtube];

  group('InstalledAppsFilter.visible', () {
    test('returns every app for an empty query, including system apps', () {
      expect(InstalledAppsFilter.visible(apps: apps, query: ''), apps);
      expect(InstalledAppsFilter.visible(apps: apps, query: '   '), apps);
    });

    test('matches the label or the package name ignoring case and whitespace', () {
      expect(InstalledAppsFilter.visible(apps: apps, query: ' CHROME '), [chrome]);
      expect(InstalledAppsFilter.visible(apps: apps, query: 'mozilla'), [firefox]);
      expect(InstalledAppsFilter.visible(apps: apps, query: 'com.'), [chrome, youtube]);
      expect(InstalledAppsFilter.visible(apps: apps, query: 'telegram'), isEmpty);
    });

    test('puts pinned apps first and keeps the order within both groups', () {
      expect(
        InstalledAppsFilter.visible(apps: apps, query: '', pinned: {youtube.packageName, chrome.packageName}),
        [chrome, youtube, firefox],
      );
      expect(
        InstalledAppsFilter.visible(apps: apps, query: 'o', pinned: {firefox.packageName}),
        [firefox, chrome, youtube],
      );
    });
  });

  group('InstalledAppsFilter.missing', () {
    test('returns the selected packages that are not installed, in selection order', () {
      expect(
        InstalledAppsFilter.missing(
          apps: apps,
          selected: ['org.telegram.messenger', chrome.packageName, 'com.whatsapp'],
        ),
        ['org.telegram.messenger', 'com.whatsapp'],
      );
    });

    test('applies the query to the package names', () {
      expect(
        InstalledAppsFilter.missing(
          apps: apps,
          selected: ['org.telegram.messenger', 'com.whatsapp'],
          query: 'TELEGRAM',
        ),
        ['org.telegram.messenger'],
      );
    });

    test('is empty when everything selected is installed', () {
      expect(InstalledAppsFilter.missing(apps: apps, selected: [firefox.packageName]), isEmpty);
    });
  });
}
