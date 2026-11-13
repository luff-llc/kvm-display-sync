# v0.1.0 — Initial Mac app preview

KVM Display Sync by LUFF adds a native macOS interface to AtakanMavzer's open-source KVM display recovery engine. The original Git history and MIT notices are preserved.

## Included

- Guided monitor and USB-hub detection by switching the KVM away and back.
- Automatic display recovery with a service that starts at login.
- Menu-bar access, status details, pause/resume, logs, and service uninstall.
- Shared Swift core for the app and CLI; typed hardware discovery.
- EDID serial targeting and ambiguity checks for matching monitor models.
- Recovery of the built-in screen's position as well as the external screen.
- Validated numeric arguments and safer service reinstall behavior.
- Eleven regression tests covering configuration, selection, recovery, and process execution.

## Requirements and validation

This download targets Apple Silicon and macOS 14 or later. Hardware validation is currently limited to a MacBook with an ASUS monitor (EDID vendor 1715, model 13042) and Realtek KVM USB hub (0x0BDA:0x5411), on macOS 27.0.1. Other monitor models and earlier macOS releases need testing.

The built-in display must be available. The monitor's USB hub must follow the KVM switch. Monitors with missing or duplicated serial identifiers cannot always be distinguished; ambiguous matches are left untouched.

The app and helper are Developer ID signed. Apple notarization was accepted and the ticket stapled. The final ZIP was extracted and passed code-signature, stapled-ticket, and Gatekeeper verification. The KVM switch away and return were observed on the test Mac: the hub disappeared and returned, mirror mode was applied, and the original main display and built-in-screen position were restored. Pause and resume were also exercised. The refactored engine passed all 11 regression tests; its updated service was installed and confirmed in sync. The final native app interface was visually checked after unlocking the test Mac and showed the restored display and running service.

Release publisher: `Developer ID Application: LUFF LLC (J53CA7SFMK)`. The app and helper use the company's Developer ID certificate, separate from its Mac App Store/TestFlight distribution certificate. Apple accepted this publisher-corrected build under submission `8fac4792-8112-4721-88e1-6ebbf0a0431b` on November 13, 2026.

## Attribution

Original engine: [AtakanMavzer/kvm-display-sync](https://github.com/AtakanMavzer/kvm-display-sync). Native app and maintenance: LUFF. Both are MIT licensed.
