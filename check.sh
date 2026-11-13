#!/bin/zsh
set -euo pipefail
cd "${0:A:h}"
swift test --scratch-path "${KVM_BUILD_ROOT:-../../work/package-build}/package"
plutil -lint Info.plist
