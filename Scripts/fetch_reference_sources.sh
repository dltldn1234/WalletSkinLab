#!/bin/bash
set -euo pipefail
# This is optional SOURCE REVIEW only. It does NOT build/run/install exploits.
# Network needed. Review upstream licenses before reusing code.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/Research/Upstream"
mkdir -p "$DEST"
while IFS='|' read -r name url; do
  [[ -n "$name" ]] || continue
  if [[ -d "$DEST/$name/.git" ]]; then
    echo "SKIP: $name already cloned"
  else
    git clone --depth 1 "$url" "$DEST/$name"
  fi
done <<'REPOS'
AirCard-iOS|https://github.com/Mak5er/AirCard-iOS.git
AirLift|https://github.com/0xjohnnydev/airlift.git
worse_query|https://github.com/forcequitOS/worse_query.git
WQFiles|https://github.com/kolbicz/WQFiles.git
REPOS
printf '참고 소스만 다운로드했습니다. 자동 실행/빌드/접근 권한 부여 없음.\n'
