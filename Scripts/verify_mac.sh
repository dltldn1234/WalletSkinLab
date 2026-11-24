#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
xcodebuild -version
swift --version
swift test --package-path Core
cd Native
if command -v xcodegen >/dev/null; then xcodegen generate; fi
products="$(mktemp -d)"
xcodebuild -project WalletSkinLab.xcodeproj -scheme WalletSkinLab -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath "$products" CODE_SIGNING_ALLOWED=NO build
if [[ -n "${SIMULATOR_UDID:-}" ]]; then
  xcrun simctl bootstatus "$SIMULATOR_UDID" -b
  xcrun simctl install "$SIMULATOR_UDID" "$products/Build/Products/Debug-iphonesimulator/WalletSkinLab.app"
  xcrun simctl launch "$SIMULATOR_UDID" dev.walletskinlab.integrated
fi
