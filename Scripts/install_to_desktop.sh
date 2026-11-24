#!/bin/bash
set -euo pipefail

# Run this script from the unpacked WalletSkinLab-Integrated folder.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASE="$HOME/Desktop/WalletSkinLab-Integrated"
DEST="$BASE"
if [[ "$ROOT" == "$BASE" ]]; then
  echo "이미 데스크탑에 설치되어 있어: $BASE"
  exit 0
fi
if [[ -e "$DEST" ]]; then
  diff -qr -x .git -x .build "$ROOT" "$DEST" || true
  echo "기존 프로젝트를 확인하세요: $DEST"
  exit 2
fi
mkdir -p "$HOME/Desktop"
rsync -a --exclude='.build' --exclude='*.xcuserstate' "$ROOT/" "$DEST/"
echo "완료: $DEST"
echo "웹 편집기: $DEST/Web/WalletSkinLab.html"
echo "Xcode 프로젝트 생성: cd \"$DEST/Native\" && xcodegen generate"
if command -v open >/dev/null 2>&1; then
  open "$DEST" || true
fi
