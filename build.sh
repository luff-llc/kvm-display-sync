#!/bin/zsh
set -euo pipefail
cd "${0:A:h}"
BUILD_ROOT="${KVM_BUILD_ROOT:-../../work/package-build}"
APP_PATH="${KVM_APP_PATH:-../KVM Display Sync.app}"
mkdir -p "$BUILD_ROOT" "$APP_PATH/Contents/MacOS" "$APP_PATH/Contents/Helpers" "$APP_PATH/Contents/Resources"
swift build -c release --scratch-path "$BUILD_ROOT/package"
cp "$BUILD_ROOT/package/release/kvm-display-sync" "$APP_PATH/Contents/Helpers/"
cp "$BUILD_ROOT/package/release/KVMDisplaySync" "$APP_PATH/Contents/MacOS/KVMDisplaySync"
cp Info.plist "$APP_PATH/Contents/Info.plist"
swift make-icon.swift "$BUILD_ROOT/AppIcon.iconset"
iconutil -c icns "$BUILD_ROOT/AppIcon.iconset" -o "$APP_PATH/Contents/Resources/AppIcon.icns"
cp Licenses/AtakanMavzer-MIT.txt "$APP_PATH/Contents/Resources/UPSTREAM-LICENSE.txt"
cp LICENSE "$APP_PATH/Contents/Resources/LUFF-LICENSE.txt"
xattr -cr "$APP_PATH"
if [[ -n "${KVM_SIGN_IDENTITY:-}" ]]; then
    codesign --force --options runtime --timestamp --sign "$KVM_SIGN_IDENTITY" "$APP_PATH/Contents/Helpers/kvm-display-sync"
    codesign --force --options runtime --timestamp --sign "$KVM_SIGN_IDENTITY" "$APP_PATH"
else
    codesign --force --sign - "$APP_PATH"
fi
codesign --verify --deep --strict --verbose=2 "$APP_PATH"
