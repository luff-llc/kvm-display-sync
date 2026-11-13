# KVM Display Sync by LUFF

An independently maintained native macOS app by LUFF, based on [AtakanMavzer/kvm-display-sync](https://github.com/AtakanMavzer/kvm-display-sync). The original project provides the USB detection and display recovery engine. This companion adds a SwiftUI setup wizard, menu-bar access, service status, pause/resume, logs, and uninstall.

## Requirements

- Apple Silicon Mac, macOS 14 or later. This build was compiled and exercised on macOS 27.0.1; earlier supported versions still need hardware validation.
- A built-in display, open and available for mirroring.
- A monitor/KVM whose USB hub disappears when switched away and returns when switched back.

## Install and set up

1. Copy `KVM Display Sync.app` to Applications and open it.
2. With the KVM showing the Mac, choose the monitor and capture the USB devices.
3. Switch to the other computer and compare USB devices using the Mac's built-in keyboard and screen.
4. Select the monitor's hub, switch back to the Mac, and enable automatic sync.

The service starts at login. The app itself does not need to stay open. macOS may display a background-item notice; leave the service enabled under System Settings > General > Login Items & Extensions.

Pause unloads the service and restores the display. Resume starts it again. Pause lasts until resume or the next login. Uninstall Service stops automatic sync and removes its login agent and copied helper; the app remains available for setup again.

## How it works

When the KVM routes USB away, the engine mirrors the monitor onto the built-in screen. It preserves the video signal while removing invisible desktop space. When USB returns, it restores the display arrangement. This app exposes mirror mode only. It does not require BetterDisplay.

Limitations: closing the MacBook lid removes the mirror target; monitors with identical vendor/model IDs and missing or duplicated EDID serial numbers cannot be distinguished reliably; ambiguous matches are left untouched; USB hubs shared by several devices must be chosen carefully. Sleep/wake, lid changes, and other KVM models require further hardware testing before broad compatibility claims.

## Local storage

- `~/.local/bin/kvm-display-sync`: signed helper installed by setup
- `~/Library/LaunchAgents/io.github.kvm-display-sync.plist`: startup configuration
- `~/Library/Logs/kvm-display-sync.log`: diagnostic log
- `~/Library/Application Support/kvm-display-sync/`: display restoration state

No telemetry, accounts, network service, or analytics are added by the wrapper. The runtime operates locally. Notarization sends the app artifact to Apple, not these local configuration files.

## Build

Xcode with Swift 6.2 or later is needed; this source was built with Swift 6.4.2. No third-party dependencies are fetched during the build.

The package has three targets: `KVMCore` (hardware, display recovery, configuration), `kvm-display-sync` (CLI/login service), and `KVMSyncApp` (native interface). Both executables use the same core; hardware discovery does not parse CLI output. The existing event-driven engine remains in Swift 5 compatibility mode while the new interface uses Swift 6 with main-actor isolation.

```sh
zsh build.sh
```

The default build writes `.build/dist/KVM Display Sync.app`, ad-hoc signed for local use. To sign a release with your own Developer ID:

```sh
KVM_SIGN_IDENTITY='Developer ID Application: Your Name (TEAMID)' \
KVM_APP_PATH='/private/tmp/KVM Display Sync.app' zsh build.sh
```

For public distribution, notarize the resulting archive and staple Apple's ticket to the app before producing the final ZIP. Developer credentials and signing keys are not included in this source.

Run the focused source checks using `zsh check.sh`.

## Attribution and source

Original engine: AtakanMavzer/kvm-display-sync commit `ea8f58053d937415cb8e761b55dfef08b024702d`, MIT licensed. The original Git history is retained. The LUFF changes extract a shared core, add EDID serial targeting and input validation, repair built-in-screen position checks during recovery, remove shared mutable output collection from shell execution, and create the Logs directory at installation. See `Licenses/AtakanMavzer-MIT.txt`.

The original command-line documentation is preserved in `docs/CLI.md`. Public distribution is maintained independently by LUFF; it is not endorsed by the original author.

The LUFF companion app is MIT licensed; see `LICENSE`. The icon uses Apple's standard display symbol, also used by the dashboard.
