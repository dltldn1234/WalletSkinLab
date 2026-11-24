# Wallet 카드 이미지 연동 검토

이 앱에서 제공하는 어댑터는 디자인 미리보기 전용이다. 아래 표는 공개 저장소 작성자의 보고를 정리한 것이다. 동일 기기·OS 빌드에서 수행한 독립적인 재현 기록은 확보하지 못했다.

|프로젝트 및 조사 기준 커밋|공개 지원 범위와 결과|앱에 반영한 판단|
|---|---|---|
|[AirCard-iOS](https://github.com/Mak5er/AirCard-iOS/tree/40640c4d827aeab8d798285b57d24fcf6be070d0)|iOS 18~26.x, 27.0~27.0.1, 27.2 beta 1~2의 Wallet 스킨 지원을 기재. beta 3 이후 실패 보고.|기기 버전 문자열만으로 베타 빌드 구분 불가. 적용 엔진 미포함.|
|[AirCard](https://github.com/Mak5er/AirCard/tree/52ba05dca4bdc590672c19d554701f4438e20338)|데스크탑에서 AirLift에 의존. 18.0~27.0.1 및 27.2 beta 1~2 지원, beta 3 이후 패치로 표기.|동일 계열 근거로 분류. 독립 검증 건수에 중복 합산하지 않음.|
|[AirLift](https://github.com/0xjohnnydev/airlift/tree/e318739ca8b35b7eab6b2adc05e0131b1aa83449)|iOS 27.0과 페어링된 Mac 대상 시스템 보안 연구. README 자체에서 27.2 패치 설명은 찾지 못함.|beta 3 패치 주장의 출처는 AirCard 계열. 결제 자격 증명이나 Wallet 지원 판정에 사용하지 않음.|
|[worse_query](https://github.com/forcequitOS/worse_query/tree/d1540e20cd82b974d891e0551ced6d6aeb570ac2)|작성자는 iOS 26.0~26.7.2 / 27.2 대상 컨테이너 접근 개념증명으로 소개.|일부 컨테이너 열람은 Wallet 이미지 쓰기 증거가 아님.|
|[WQFiles](https://github.com/kolbicz/WQFiles/tree/a8a4d06cbf2651de1cd7bd9f5f8e38f67b025890)|worse_query 기반 파일 관리 앱. 작성자 기기 목록과 27.2 사용자 보고가 있음. 읽기·백업·정리 기능의 범위는 컨테이너마다 다름.|Wallet 카드 이미지 수정 성공 근거 미확보.|
|[AirCard-Linux](https://github.com/kmw0410/AirCard-Linux/tree/30a1f158b8a9066000f48dc17e50be8422ffd693)|GTK4/libadwaita 포트. 작성자는 27.2 아이폰에서 Wallet 스킨 변경을 확인했다고 적음. 정확한 빌드와 베타 차수는 명시하지 않음.|업스트림과 보고가 충돌한다. 전송 완료와 Wallet 화면에서 보이는 변경은 별도 관찰 항목이다.|

제3자 시스템 접근 코드는 재사용하지 않았다. 디자인 프리셋·비율 계산·자체 앱 저장소 진단은 독립 구현으로 유지한다. [Apple의 PassKit 가용성 검사](https://developer.apple.com/documentation/passkit/pkpasslibrary/ispasslibraryavailable())는 패스 라이브러리 사용 가능 여부만 반환한다.

## 추가 근거가 필요한 항목

- 동일 OS 빌드와 기기 모델을 명시한 작성자 기록, 변경 전후의 비민감한 시각적 결과, 재시작 후 표시 상태. Linux 포트의 27.2 표기를 정식판 성공으로 분류하기 전에 확인한다.
- 향후 발급사가 공식적으로 아트워크 갱신을 제공하면 자격, 배포 범위와 권한 문서를 검토한다. 현재 카카오뱅크 발급 카드의 사용자 지정 API 근거는 확보하지 못했다.
