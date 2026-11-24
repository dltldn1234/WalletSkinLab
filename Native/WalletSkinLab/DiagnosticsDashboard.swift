import SwiftUI
import Darwin
import PassKit
import WalletSkinCore

struct DiagnosticsDashboard: View {
    @State private var report: String = ""
    @State private var lastRun: Date?
    @State private var testStorage = false
    @State private var storageResult = "미실행"
    @State private var libraryAvailable = false
    @State private var canAddPasses = false

    private var version: DeviceVersion {
        let v = ProcessInfo.processInfo.operatingSystemVersion
        return DeviceVersion(major: v.majorVersion, minor: v.minorVersion, patch: v.patchVersion)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 17) {
                    Text("iOS 권한 진단")
                        .font(.title2.weight(.bold))
                    Text("Wallet 시스템 파일을 읽거나 수정하지 않는 기기 상태 확인이야.")
                        .font(.subheadline).foregroundStyle(.secondary)
                    diagnosticCard("iOS 버전", value: version.description, symbol: "iphone")
                    diagnosticCard("PassKit 사용 가능", value: lastRun == nil ? "검사 전" : (libraryAvailable ? "예" : "아니요"), symbol: "creditcard")
                    diagnosticCard("일반 패스 추가 가능", value: lastRun == nil ? "검사 전" : (canAddPasses ? "예" : "아니요"), symbol: "plus.rectangle.on.rectangle")
                    diagnosticCard("OS 빌드", value: systemValue("kern.osversion"), symbol: "gear")
                    diagnosticCard("하드웨어 모델", value: systemValue("hw.machine"), symbol: "iphone")
                    Toggle("앱 임시 폴더 쓰기 검사 포함", isOn: $testStorage)
                    diagnosticCard("최근 저장 공간 검사", value: storageResult, symbol: "folder")
                    Button(action: runDiagnostics) {
                        Label("안전한 진단 실행", systemImage: "stethoscope")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    if lastRun != nil {
                        ShareLink(item: report) {
                            Label("개인정보 제외 진단 로그 공유", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.bordered)
                        Text(report).font(.caption.monospaced()).textSelection(.enabled)
                            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                            .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
                    }
                    Label("이 검사는 결제 카드 목록·카드 번호·토큰·Wallet 캐시 경로를 요청하지 않아.", systemImage: "lock.shield")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .padding(18)
            }
            .navigationTitle("진단")
            .background(Color(hex: 0x0b111d).ignoresSafeArea())
        }
    }

    private func diagnosticCard(_ title: String, value: String, symbol: String) -> some View {
        HStack {
            Image(systemName: symbol).frame(width: 28).foregroundStyle(.yellow)
            Text(title).font(.subheadline)
            Spacer()
            Text(value).font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
        }
        .padding(15)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 14))
    }

    private func systemValue(_ name: String) -> String {
        var size = 0
        guard sysctlbyname(name, nil, &size, nil, 0) == 0, size > 0 else { return "확인 불가" }
        var bytes = [CChar](repeating: 0, count: size)
        guard sysctlbyname(name, &bytes, &size, nil, 0) == 0 else { return "확인 불가" }
        return String(cString: bytes)
    }

    private func runDiagnostics() {
        // Public PassKit capability probes only. Never accesses financial passes.
        libraryAvailable = PKPassLibrary.isPassLibraryAvailable()
        canAddPasses = PKAddPassesViewController.canAddPasses()
        let testFile = FileManager.default.temporaryDirectory.appendingPathComponent("walletskinlab-probe-\(UUID().uuidString).txt")
        storageResult = "미실행"
        if testStorage {
        do {
            try Data("test".utf8).write(to: testFile, options: .atomic)
            storageResult = try Data(contentsOf: testFile) == Data("test".utf8) ? "정상" : "내용 불일치"
            try FileManager.default.removeItem(at: testFile)
        } catch {
            let failure = error as NSError
            storageResult = "\(failure.domain) (\(failure.code))"
            try? FileManager.default.removeItem(at: testFile)
        }
        }
        lastRun = Date()
        let results = CompatibilityAssessment.findings(for: version)
        let airLift = results.first { $0.feature == .airlift }
        report = """
        WalletSkinLab / Read-only Diagnostics
        iOS: \(version.description)
        Build: \(systemValue("kern.osversion"))
        Hardware: \(systemValue("hw.machine"))
        Run: \(Date().ISO8601Format())
        PassKit available: \(libraryAvailable)
        Add standard passes: \(canAddPasses)
        Own temporary sandbox roundtrip: \(storageResult)
        AirLift assessment: \(airLift?.detail ?? "Unknown")
        Protected Wallet read/write attempted: NO
        Exploit invocation attempted: NO
        Actual payment card art modified: NO
        """
    }
}
