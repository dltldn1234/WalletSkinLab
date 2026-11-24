import Foundation

/// A feature state supported by documented evidence, not a vulnerability test.
public enum EvidenceLevel: String, Codable, CaseIterable, Sendable {
    case documented = "공식 문서 / README 확인"
    case unverified = "실기기 미검증"
    case unsupported = "공개 구현상 미지원"
}

public enum IntegrationFeature: String, CaseIterable, Identifiable, Sendable {
    case artwork = "디자인 내보내기"
    case passKit = "공식 Wallet 지원"
    case airlift = "AirLift 적용 엔진"
    case worseQuery = "worse_query 접근 범위"
    case cardArt = "기존 Apple Pay 카드 변경"

    public var id: Self { self }
}

public struct IntegrationFinding: Equatable, Sendable {
    public let feature: IntegrationFeature
    public let supported: Bool
    public let evidence: EvidenceLevel
    public let detail: String
    public let referenceURL: URL?

    public init(feature: IntegrationFeature, supported: Bool, evidence: EvidenceLevel, detail: String, referenceURL: URL? = nil) {
        self.feature = feature
        self.supported = supported
        self.evidence = evidence
        self.detail = detail
        self.referenceURL = referenceURL
    }
}

public struct DeviceVersion: Equatable, Comparable, Codable, Sendable {
    public let major: Int
    public let minor: Int
    public let patch: Int

    public init(major: Int, minor: Int, patch: Int = 0) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        [lhs.major, lhs.minor, lhs.patch].lexicographicallyPrecedes([rhs.major, rhs.minor, rhs.patch])
    }

    public var description: String { "\(major).\(minor).\(patch)" }
}

/// Read-only compatibility *assessment*. Does not attempt file access outside the app sandbox.
public enum CompatibilityAssessment {
    public static func findings(for version: DeviceVersion) -> [IntegrationFinding] {
        let patched = version >= DeviceVersion(major: 27, minor: 2)
        return [
            IntegrationFinding(
                feature: .artwork, supported: true, evidence: .documented,
                detail: "앱 안에서 미리보기, 커스텀 이미지 가져오기, 1536×969 PNG 생성 지원. 결제 카드 데이터와 분리됨."
            ),
            IntegrationFinding(
                feature: .passKit, supported: true, evidence: .documented,
                detail: "PassKit은 발급된 일반 패스 추가 등 공식 기능을 제공함. 기존 발급사의 결제 카드 디자인 수정 API는 없음.",
                referenceURL: URL(string: "https://developer.apple.com/documentation/passkit")
            ),
            IntegrationFinding(
                feature: .airlift, supported: false, evidence: patched ? .unsupported : .unverified,
                detail: patched
                  ? "AirCard 작성자는 27.2 beta 3 이후 패치를 보고함. OS 버전 번호만으로 베타 빌드를 구분할 수 없음. 앱에 적용 엔진 없음."
                  : "과거 iOS에서 작동한 보고가 있지만 현재 기기에서 검증한 결과는 아님.",
                referenceURL: URL(string: "https://github.com/Mak5er/AirCard-iOS")
            ),
            IntegrationFinding(
                feature: .worseQuery, supported: false, evidence: .unverified,
                detail: "일부 컨테이너 접근 보고는 있지만 Apple Wallet 카드 이미지 영역의 읽기/쓰기 접근을 입증하지 못함. 이 앱에는 취약점 코드를 포함하지 않음.",
                referenceURL: URL(string: "https://github.com/forcequitOS/worse_query")
            ),
            IntegrationFinding(
                feature: .cardArt, supported: false, evidence: .unsupported,
                detail: "사용자가 등록한 결제 카드의 실제 Wallet 표시 이미지 변경 기능은 구현되지 않았음. 발급사 전용 기능과 구별해야 함."
            )
        ]
    }
}

public struct ArtworkMetadata: Codable, Equatable, Sendable {
    public let format: String
    public let width: Int
    public let height: Int
    public let style: String
    public let createdAt: Date

    public init(style: String, createdAt: Date = Date()) {
        self.format = "png"
        self.width = 1536
        self.height = 969
        self.style = style
        self.createdAt = createdAt
    }
}

public enum ApplyResult: Equatable, Sendable {
    case previewReady
    case unavailable(reason: String)
}

/// Adapter boundary: never claims a Wallet modification on unsupported OS versions.
public protocol CardArtworkApplying {
    func prepareForPreview(_ artwork: ArtworkMetadata) -> ApplyResult
    func applyToPaymentCard(_ artwork: ArtworkMetadata) -> ApplyResult
}

public struct PreviewOnlyAdapter: CardArtworkApplying, Sendable {
    public init() {}
    public func prepareForPreview(_ artwork: ArtworkMetadata) -> ApplyResult { .previewReady }
    public func applyToPaymentCard(_ artwork: ArtworkMetadata) -> ApplyResult {
        .unavailable(reason: "지원되는 Apple Wallet 결제 카드 적용 엔진이 연결되어 있지 않습니다.")
    }
}

/// Source references are NOT automatically downloaded, run, or granted access.
public struct OpenSourceReference: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let detail: String
    public let url: URL

    public static let all: [OpenSourceReference] = [
        .init(id: "aircard", title: "AirCard-iOS", detail: "과거 Apple Wallet 이미지 캐시 교체 구현. 27.2 정식판 미지원.", url: URL(string: "https://github.com/Mak5er/AirCard-iOS")!),
        .init(id: "airlift", title: "AirLift", detail: "패치된 AirTraffic 취약점의 공개 연구 코드.", url: URL(string: "https://github.com/0xjohnnydev/airlift")!),
        .init(id: "worse", title: "worse_query", detail: "제한적인 컨테이너 접근 연구. Wallet 이미지 변경 입증 없음.", url: URL(string: "https://github.com/forcequitOS/worse_query")!),
        .init(id: "wqfiles", title: "WQ Files", detail: "파일 조회 및 권한/에러 관찰 도구. 민감 데이터 접근 주의.", url: URL(string: "https://github.com/kolbicz/WQFiles")!),
        .init(id: "desktop", title: "AirCard", detail: "데스크탑용 Wallet 스킨 프로젝트. 작성자가 beta 3 이후 미지원으로 표기.", url: URL(string: "https://github.com/Mak5er/AirCard")!),
        .init(id: "linux", title: "AirCard-Linux", detail: "GTK 포트. 작성자의 27.2 성공 보고에 빌드 번호가 없어 상위 프로젝트와 대조 필요.", url: URL(string: "https://github.com/kmw0410/AirCard-Linux")!),
        .init(id: "passkit", title: "Apple PassKit", detail: "공식 Wallet API. 제3자 카드 디자인 변경은 제공하지 않음.", url: URL(string: "https://developer.apple.com/documentation/passkit")!)
    ]
}
