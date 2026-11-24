import SwiftUI
import WalletSkinCore

struct IntegrationDashboard: View {
    @State private var previewMessage: String?

    private var findings: [IntegrationFinding] {
        let v = ProcessInfo.processInfo.operatingSystemVersion
        return CompatibilityAssessment.findings(
            for: DeviceVersion(major: v.majorVersion, minor: v.minorVersion, patch: v.patchVersion)
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("연동 가능성")
                        .font(.title2.weight(.bold))
                    Text("실제 코드로 연결된 기능과 공개 자료만 있는 기능을 분리해 보여 줘.")
                        .font(.subheadline).foregroundStyle(.secondary)
                    ForEach(findings, id: \.feature) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top) {
                                Image(systemName: item.supported ? "checkmark.circle.fill" : "exclamationmark.shield.fill")
                                    .foregroundStyle(item.supported ? .green : .orange)
                                Text(item.feature.rawValue).font(.headline)
                                Spacer(minLength: 10)
                                Text(item.evidence.rawValue)
                                    .font(.caption2).foregroundStyle(.secondary)
                                    .multilineTextAlignment(.trailing)
                            }
                            Text(item.detail).font(.caption).foregroundStyle(.secondary)
                            if let url = item.referenceURL {
                                Link("공개 원본 보기", destination: url).font(.caption.weight(.semibold))
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 14))
                    }
                    Button {
                        let demo = ArtworkMetadata(style: "Gold")
                        switch PreviewOnlyAdapter().prepareForPreview(demo) {
                        case .previewReady: previewMessage = "디자인 미리보기 엔진 정상. 실제 Wallet 적용은 시도하지 않았어."
                        case .unavailable(let reason): previewMessage = reason
                        }
                    } label: {
                        Label("연동 인터페이스 자체 검사", systemImage: "checkmark.shield")
                            .frame(maxWidth: .infinity)
                    }.buttonStyle(.borderedProminent)
                    if let previewMessage {
                        Text(previewMessage).font(.caption).foregroundStyle(.green)
                    }
                    Label("Apple Pay 결제 카드 변경 버튼은 지원 엔진이 없어 제공하지 않아.", systemImage: "lock.fill")
                        .font(.caption).foregroundStyle(.secondary)
                }.padding(18)
            }
            .navigationTitle("연동")
            .background(Color(hex: 0x0b111d).ignoresSafeArea())
        }
    }
}

struct ResearchSourcesView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("공개 프로젝트") {
                    ForEach(OpenSourceReference.all) { reference in
                        Link(destination: reference.url) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(reference.title).font(.headline).foregroundStyle(.primary)
                                Text(reference.detail).font(.caption).foregroundStyle(.secondary)
                            }.padding(.vertical, 4)
                        }
                    }
                }
                Section("안전 정책") {
                    Text("이 프로젝트는 공개 기술을 비교하되, 악용 가능한 시스템 침투 코드나 Apple Pay 카드 데이터 추출 기능은 번들에 포함하지 않아.")
                    Text("제3자 취약점 도구가 설치됐다는 이유만으로 실제 카드 디자인 적용에 성공했다고 표시하지 않아.")
                }
            }
            .navigationTitle("연구 자료")
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            EditorView()
                .tabItem { Label("디자인", systemImage: "paintpalette.fill") }
            DiagnosticsDashboard()
                .tabItem { Label("진단", systemImage: "stethoscope") }
            IntegrationDashboard()
                .tabItem { Label("연동", systemImage: "point.3.connected.trianglepath.dotted") }
            ResearchSourcesView()
                .tabItem { Label("자료", systemImage: "books.vertical") }
        }
        .tint(Color(hex: 0xe6c784))
    }
}
