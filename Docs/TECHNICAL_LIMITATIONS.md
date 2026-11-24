# 기술 검토 보고: iOS 27.2 결제 카드 아트 (2026-11-23)

## 확인된 공개 자료

| 소스 | 공개된 기능 | Wallet 결제 카드 디자인 변경 가능성 |
| --- | --- | --- |
| [AirCard-iOS](https://github.com/Mak5er/AirCard-iOS) | AirTraffic/AirLift 기반 이미지 캐시 변경 구현 | iOS 27.2 베타 3 이상은 README상 패치됨 |
| [AirLift](https://github.com/0xjohnnydev/airlift) | 과거 동기화 취약점 연구 | 패치된 버전 대체 방법 아님 |
| [worse_query](https://github.com/forcequitOS/worse_query) | 일부 iOS 앱/시스템 컨테이너 접근 PoC | Wallet 이미지 캐시 쓰기 확인 안 됨 |
| [WQ Files](https://github.com/kolbicz/WQFiles) | 일부 파일 조회 및 앱 데이터 관리 | Wallet 결제 이미지 갱신 확인 안 됨 |
| [Apple PassKit](https://developer.apple.com/documentation/passkit) | Wallet의 공식 패스 생성/추가 등 | 기존 타사 발급 결제 카드 이미지 수정 API 없음 |

### 직접 검증한 항목

- 기존 월렛 스킨 편집기의 HTML 파일과 PNG 자산을 기반으로 통합 프로젝트 생성
- Swift Package의 API/상태모델 설계, Linux `swift test` **7개 통과**
- SwiftUI 소스에 대한 `swiftc -frontend -parse` 문법 검사 **통과**
- SwiftUI가 iOS SDK에서 타입 검사되고 실제 iPhone에서 빌드·실행되는지: **미검증**
- 브라우저 E2E는 이 컨테이너의 Chromium 탐색이 관리자 정책으로 차단되어 **이번 턴 검증 불가** (기존 프로토타입 UI는 앞선 작업에서 확인됨)

### 연동(Integration)의 정확한 의미

`CardArtworkApplying` 프로토콜과 `PreviewOnlyAdapter`를 통해 **디자인 렌더링 결과와 적용 단계의 경계**를 테스트함. `applyToPaymentCard`는 항상 `unavailable`을 반환하며 결제 카드 변경을 시도하지 않음. `DiagnosticsDashboard`의 샌드박스 진단은 `FileManager.default.temporaryDirectory`만 사용.

### 실제 Apple Pay 이미지 변경의 통과 조건

1. 대상 iOS 정식 빌드에서 사용자가 의도한 이미지에 대해 적법한 접근/변경 경로가 검증되어야 함
2. 실제로 필요한 권한이 공개 근거 또는 적절한 실기기 테스트로 확인되어야 함
3. 이미지 변경이 결제 자격증명과 완전히 격리되어야 함
4. 결제 앱 안정성, 이미지 캐시 복원, OS 업그레이드 영향까지 검사되어야 함

현재 1–4를 충족하는 공개 엔진을 확보하지 못했으므로 무리하게 적용 기능을 제공하지 않음.

### 안전

본 프로젝트는 결제 카드 정보 추출·Wallet 시스템 파일 변경·샌드박스 탈출 실행 코드 또는 악용 가능한 접근 도구를 포함하지 않습니다. 테스트는 별도 기기에서 진행하세요. 임의 IPA/설치 스크립트에 Apple ID 비밀번호나 인증 코드를 입력하는 일에 주의하세요.
