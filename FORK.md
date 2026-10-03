# metaer fork: Android split tunneling

This fork adds per-app routing (split tunneling) to the Android app: you choose which apps use the
VPN. It is based on the ideas of TrustTunnel/TrustTunnelFlutterClient#70 and
TrustTunnel/TrustTunnelClient#79, reworked to follow the app's architecture.

The fork build installs **next to** the official app:

| | Official app | This fork |
|---|---|---|
| Application id | `com.adguard.trusttunnel` | `com.adguard.trusttunnel.split` |
| Launcher label | TrustTunnel | TTm |

Android allows only one active VPN at a time, so use one app or the other.

## How it works

1. **Settings → Split tunneling** (Android only) offers three modes:
   - *Off*: all apps use the VPN.
   - *Only selected apps*: only the selected apps use the VPN.
   - *All apps except selected*: the selected apps connect directly.

   The list shows every app with a launcher icon, including preinstalled ones such as Chrome or
   YouTube. Saving reconnects a connected VPN once to apply the change.
2. The settings are stored in the `app_settings` table and sent to the client library in the
   `[listener.tun]` section of the configuration:

   ```toml
   split_tunnel_mode = "include"   # "off" | "include" | "exclude"
   split_tunnel_apps = ["com.android.chrome"]
   ```

   Other platforms always send `off`; the native core ignores both keys.
3. The client library ([metaer/TrustTunnelClient](https://github.com/metaer/TrustTunnelClient),
   branch `split-tunnel`) applies them with `VpnService.Builder.addAllowedApplication` /
   `addDisallowedApplication`. Uninstalled apps are skipped. If *Only selected apps* ends up with no
   installed app, it falls back to routing every app through the VPN instead of failing.

## One-time setup (GitHub)

1. **Enable Actions** in both forks (Actions tab → enable workflows).
2. In this repository, **disable the inherited upstream workflows** (Actions → workflow → ⋯ →
   Disable workflow): *Testing*, *Build & Deploy*, *Tag and deploy*, *Mirror*. They need AdGuard's
   self-hosted runners, private registry and Vault. Disable them in the UI instead of deleting the
   files, so rebasing on upstream stays conflict-free.
3. **Create a classic personal access token** with the `read:packages` scope
   (github.com/settings/tokens → Generate new token (classic)) and add it as the repository secret
   **`GPR_KEY`** in **both** forks (Settings → Secrets and variables → Actions). GitHub Packages
   requires a token even for public packages, and the workflow token of one repository cannot read
   another repository's Maven packages. Note the token's expiry date.
4. **Add the signing secrets** to this repository so that every build can update the installed app:

   | Secret | Value |
   |---|---|
   | `KEYSTORE_BASE64` | `base64 -i android/trusttunnel.keystore` |
   | `KEYSTORE_PASSWORD` | `signingConfigKeyStorePassword` from `android/local.properties` |
   | `KEY_ALIAS` | `trusttunnel` |
   | `KEY_PASSWORD` | `signingConfigKeyPassword` from `android/local.properties` |

   `android/trusttunnel.keystore` and `android/local.properties` are git-ignored; back them up.
   Losing the keystore means future builds cannot update installed copies. Without these secrets
   the workflow signs every build with a throwaway key, so you must uninstall before installing the
   next build (the server list and settings are lost).

## Building

### GitHub Actions (recommended)

1. **Client library** (metaer/TrustTunnelClient, workflow *Fork - Android library*): every push to
   `split-tunnel` runs the unit tests and builds the AAR. To publish a version, push a tag
   `android-lib/v1.1.5-rc.6-split.<n>`; the package then appears under the repository's Packages.
   Versions cannot be overwritten, so every change needs a new `<n>`.
2. **App** (this repository, workflow *Fork - Build Android APK*): every push to `split-tunnel`
   checks formatting, analyzes, runs the tests and builds two APKs, attached to the run as an artifact:
   - `…-universal.apk` for any device;
   - `…-arm64.apk`, smaller, for 64-bit ARM phones (Pixel 6 and newer).

   Pushing a tag `v<app version>-split.<n>` (for example `v1.2.0-split.1`), or running the workflow
   manually with *release* checked, also publishes a GitHub pre-release with both APKs.

The library version the app uses is `ttLibVersion` in `android/gradle.properties`. To try a new
library version before committing it, run the app workflow manually with *lib-version*.

### Local build

Code generation, analysis and tests only need the Flutter SDK (3.38.3, as pinned in `pubspec.yaml`).
The format check covers tracked files only, because generated files are not formatted:

```bash
git ls-files '*.dart' | xargs dart format -o none --set-exit-if-changed
make init
flutter analyze
flutter test
```

A full APK build additionally needs JDK 17, the Android SDK (`platforms;android-36`,
`build-tools;35.0.0`, `platform-tools`, `ndk;29.0.14206865`), the signing configuration in
`android/local.properties` (`make aux-setup-android-signing` creates it) and a `GPR_KEY` token:

```bash
export GPR_KEY=<classic token with read:packages>
make init
flutter build apk --release --build-name=1.2.0-split.local --build-number=1
```

`flutter build` cannot pass `-P` options to Gradle; override the `tt*` properties with environment
variables instead, for example `ORG_GRADLE_PROJECT_ttLibVersion=1.1.5-rc.6-split.2 flutter build apk …`.

To build against a local checkout of the client library instead of GitHub Packages, copy
`android/template.libs.gradle` to `android/libs.gradle` (git-ignored) and point `includeBuild` at the
client's `platform/android` directory, either with an absolute path or relative to `android/`
(`../../metaerTrustTunnelClient/platform/android` for sibling checkouts). Pass the official native
libraries with `ORG_GRADLE_PROJECT_ttPrebuiltNativeDir=<dir with <abi>/libtrusttunnel_android.so>`
(see `platform/android/README.md` in the client repository).

## Versions and tags

| Repository | Tag | Result |
|---|---|---|
| metaer/TrustTunnelClient | `android-lib/v1.1.5-rc.6-split.<n>` | Maven package `com.adguard.trusttunnel:trusttunnel-client-android:1.1.5-rc.6-split.<n>` |
| metaer/TrustTunnelFlutterClient | `v<app version>-split.<n>` | GitHub pre-release with the APKs |

The client library is based on tag `v1.1.5-rc.6`, the version upstream's app uses.

## Updating

- **New client library change:** commit it on `split-tunnel` in the client fork, tag
  `android-lib/v1.1.5-rc.6-split.<n+1>`, then set `ttLibVersion` in `android/gradle.properties`.
- **Rebasing on upstream:** `git fetch upstream && git rebase upstream/master` on `split-tunnel`.
  If upstream changes the client library version in `plugins/vpn_plugin/android/build.gradle`,
  keep the `$ttLibVersion` line, update its default, rebase the client fork's `split-tunnel` onto
  the matching tag, publish `<tag>-split.1` and update `ttLibVersion`.

Fork-only changes, to leave out of upstream pull requests: this file,
`.github/workflows/fork-build-apk.yml` and the `tt*` lines in `android/gradle.properties`. Everything
else (the split tunneling feature, tests and the property-driven Gradle setup) is meant to be
proposed upstream.

## Limitations

- With Android's *Block connections without VPN*, apps that do not use the VPN lose connectivity.
- Apps in a work profile are not affected by a VPN running in the personal profile.
- Android cannot change the app rules of a running VPN, so saving reconnects it.

## Checking that it works

- In *Only selected apps* mode with only Chrome selected, a "what is my IP" page shows the VPN
  address in Chrome and your own address in another browser; *All apps except selected* does the
  opposite.
- With *Settings → App logging → Sensitive data* set to *Included* (the VPN library only logs
  informational messages then), the exported logs contain a line like
  `Split tunnel: mode=include (requested=include) allowed=1 disallowed=0 dropped=0`.
