# Wallet Skin Lab — Integrated Research Build (2026-11-23)

**목적:** 블랙·골드·프리미엄 카드 스킨을 만들고, 사용자가 올린 이미지를 1536×969 PNG로 출력하며, Apple Wallet 연동 가능성을 **오인하지 않고** 진단하는 iOS 연구 프로젝트.

> ⚠️ 이 앱은 카카오뱅크 카드의 **실제 Apple Pay 결제창 이미지를 변경하지 않습니다.** iOS 27.2에서 AirLift가 패치됐고, worse_query나 WQ Files로 Wallet 카드 아트를 쓸 수 있다는 공개 검증이 없습니다. '연동' 탭은 앱 내 모듈 결합 및 공개 문서 기반 상태 판단이지 iOS 권한 우회 성공의 뜻이 아닙니다.

## 폴더

```text
WalletSkinLab-Integrated/
├── Native/                    SwiftUI iPhone 앱 (XcodeGen 프로젝트)
│   ├── project.yml
│   └── WalletSkinLab/
│       ├── EditorView.swift             스킨 편집, PhotosPicker, PNG 공유
│       ├── CardArtworkView.swift        고해상도 카드 프리뷰 및 렌더링
│       ├── DiagnosticsDashboard.swift  읽기 전용 기기/PassKit/자체 앱 저장공간 진단
│       ├── IntegrationDashboard.swift  연결 상태 및 공개 근거
│       └── Assets.xcassets/             블랙/골드 프리셋
├── Core/                      Swift Package: 호환성 평가/적용 인터페이스/테스트
├── Web/                       단일 HTML 오프라인 편집기
├── Assets/                    원본 PNG 스킨 (1536×969)
├── Docs/                      설치, 검증, 보안/제약 문서
├── Scripts/                   데스크탑 복사/연구 소스 체크아웃
└── Research/                  자료·프로토타입 스크린샷
```

## 지금 당장 실행

### 1. 디자인부터 보기 (맥/아이폰)
- `Web/WalletSkinLab.html`을 Safari 또는 Chrome에서 열면 오프라인으로 동작합니다.
- **Gold / Premium Black / Platinum / Midnight / Graphite / 내 디자인**을 선택할 수 있습니다.
- '내 디자인'은 PNG/JPG 이미지 전체가 카드 바탕이 됩니다. 드래그, 줌, 커버/맞춤을 선택한 다음 PNG 출력.
- 이 파일은 Apple Wallet에 실제로 등록된 결제 카드의 배경을 바꾸지 않습니다.

### 2. Xcode에서 네이티브 앱 실행 (맥 필요)
동봉한 `Open-Xcode.command`로 프로젝트를 열 수 있습니다. 프로젝트 재생성이 필요한 경우 다음 순서를 사용하세요.

1. Xcode와 XcodeGen 설치: `brew install xcodegen` (Homebrew 이미 설치된 경우)
2. 터미널에서 `cd ~/Desktop/WalletSkinLab-Integrated/Native`
3. `xcodegen generate`
4. `open WalletSkinLab.xcodeproj`
5. Signing & Capabilities의 Team을 본인 Apple ID 개발 팀으로 설정하고, 연결한 아이폰 선택 후 Run (▶︎)
6. 탭: **디자인 / 진단 / 연동 / 자료**

실제 iOS 27.2 실기기 빌드/설치는 **이 작업 환경에서 실행하지 못했으며**, Xcode로 현지 확인이 필요합니다.

### 3. 테스트

```bash
cd ~/Desktop/WalletSkinLab-Integrated/Core
swift test
```

- 원본에 포함된 기록은 7개 통과입니다. 변경 후에는 Swift 도구가 없는 Linux 환경이어서 재실행하지 못했습니다.
- iOS 전체 앱은 macOS/Xcode 환경이 없으므로 실제 컴파일 테스트가 아직 수행되지 않았습니다.

## 통합 범위

- ✅ SwiftUI, 사진 가져오기, 프리셋, 카드 미리보기, 고해상도 PNG 내보내기
- ✅ PassKit **공개 API** 가용성 확인(결제 카드 목록 읽기 없음)
- ✅ 앱 자체 임시 폴더 쓰기/읽기 왕복 체크(정상적인 샌드박스 내에서만)
- ✅ AirCard/AirLift/worse_query/WQFiles 공개 근거 기반 호환성 표와 출처 연결
- ✅ `CardArtworkApplying` 프로토콜과 `PreviewOnlyAdapter` 엔진 결합 및 테스트
- ❌ 실제 Wallet 보호 파일을 읽거나 수정하는 경로
- ❌ 취약점 코드 결합 및 악용, 결제 토큰/카드 정보 추출
- ❌ Apple Pay 실제 카드 변경 성공 기능 또는 iOS 27.2 우회 성공 주장

## 참고

- `Docs/TECHNICAL_LIMITATIONS.md` — 자료와 검증 범위
- `Docs/IMPLEMENTATION_CHECKLIST.md` — 완료/검증 필요 항목
- `Scripts/fetch_reference_sources.sh` — 원본 공개 GitHub 저장소를 **실행 없이 검토 목적으로만** 맥에 다운로드하는 선택 기능

**참고:** 프리미엄 블랙/골드 이미지에 등장하는 로고 등은 디자인 콘셉트일 뿐 실제 카드 발급사나 결제 브랜드를 변경하지 않습니다. 다른 사람의 카드번호, 이름, 결제정보는 앱에 입력하지 마세요.

이번 변경의 검증 기록과 맥 실행 절차는 Docs/IMPLEMENTATION_CHECKLIST.md, 여섯 저장소의 비교 결과는 Research/REVIEW.md에 있습니다.
