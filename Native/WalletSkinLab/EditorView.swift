import SwiftUI
import ImageIO
import PhotosUI
import UIKit
import UniformTypeIdentifiers

struct EditorView: View {
    @State private var design = CardDesign()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photo: UIImage?
    @State private var showingFileImporter = false
    @State private var exportItem: ExportItem?
    @State private var alertText: String?

    private var gradient: LinearGradient {
        LinearGradient(colors: [Color(hex: 0x080e18), Color(hex: 0x162238)],
                       startPoint: .top, endPoint: .bottom)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 23) {
                    header
                    preview
                    presetSection
                    textSection
                    imageSection
                    optionsSection
                    infoSection
                }
                .padding(19)
            }
            .background(gradient.ignoresSafeArea())
            .navigationTitle("Wallet Skin Lab")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("초기화") {
                        design = CardDesign(); photo = nil; selectedPhoto = nil
                        try? FileManager.default.removeItem(at: artworkFile)
                    }
                        .font(.caption)
                }
            }
            .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.png, .jpeg]) { result in
                do {
                    let url = try result.get()
                    let scoped = url.startAccessingSecurityScopedResource()
                    defer { if scoped { url.stopAccessingSecurityScopedResource() } }
                    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
                          let loaded = previewImage(source) else {
                        alertText = "이미지 파일을 열 수 없어. PNG 또는 JPG 파일을 선택해 줘."
                        return
                    }
                    selectedPhoto = nil
                    setCustomPhoto(loaded)
                } catch {
                    alertText = "파일을 가져오지 못했어: \(error.localizedDescription)"
                }
            }
            .sheet(item: $exportItem) { item in
                ShareSheet(items: [item.url])
            }
            .alert("안내", isPresented: Binding(get: { alertText != nil },
                                                 set: { if !$0 { alertText = nil } })) {
                Button("확인", role: .cancel) { alertText = nil }
            } message: {
                Text(alertText ?? "")
            }
            .onAppear(perform: loadDesign)
            .onChange(of: design) { _, newValue in
                guard let data = try? JSONEncoder().encode(newValue) else { return }
                UserDefaults.standard.set(data, forKey: "design")
            }
            .onChange(of: selectedPhoto) { _, selection in
                Task {
                    guard let selection else { return }
                    guard let data = try? await selection.loadTransferable(type: Data.self),
                          let source = CGImageSourceCreateWithData(data as CFData, nil),
                          let image = previewImage(source) else {
                        if selectedPhoto == selection { alertText = "사진을 불러오지 못했어." }; return
                    }
                    guard selectedPhoto == selection else { return }
                    setCustomPhoto(image)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("프리미엄 카드 디자인")
                .font(.system(size: 27, weight: .heavy, design: .rounded))
            Text("블랙·골드 카드 또는 내가 올린 사진으로 디자인할 수 있어.")
                .font(.subheadline).foregroundStyle(.secondary)
        }
    }

    private var preview: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                Label("디자인 프리뷰", systemImage: "creditcard.fill")
                    .font(.subheadline.weight(.bold))
                Spacer()
                Text("1536 × 969").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
            }
            CardArtworkView(design: design, photo: photo)
                .shadow(color: .black.opacity(0.45), radius: 18, y: 12)
            Button(action: exportPNG) {
                Label("PNG 저장 · 공유", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .fontWeight(.bold)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: 0x8eb5fd))
            Text("Apple Wallet 결제 화면을 변경하지 않는 디자인 미리보기야.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 19))
    }

    private var presetSection: some View {
        VStack(alignment: .leading, spacing: 11) {
            sectionHeading("스타일")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 9) {
                    ForEach(CardDesign.Preset.allCases) { option in
                        Button {
                            let wasArtwork = [.gold, .premiumBlack, .custom].contains(design.preset)
                            if option == .custom && photo == nil {
                                alertText = "내 이미지 탭은 아래에서 사진을 먼저 불러오면 선택할 수 있어."
                                return
                            }
                            design.preset = option
                            if option == .gold {
                                design.bankName = ""; design.headline = ""; design.subtitle = ""; design.footer = ""
                                design.showsChip = false; design.showsEmblem = false
                            } else if option == .premiumBlack || option == .custom {
                                design.bankName = ""; design.headline = ""; design.subtitle = ""; design.footer = ""
                                design.showsChip = false; design.showsEmblem = false
                            } else if wasArtwork {
                                design.bankName = "KAKAO BANK"; design.headline = option.title
                                design.subtitle = "PRIVATE COLLECTION"; design.footer = "DESIGN CONCEPT · 2026"
                                design.showsChip = true; design.showsEmblem = true
                            }
                        } label: {
                            HStack(spacing: 7) {
                                Circle().fill(option.colors.first ?? .black)
                                    .frame(width: 17, height: 17)
                                    .overlay(Circle().stroke(.white.opacity(0.7)))
                                Text(option.title)
                            }
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 13)
                            .padding(.vertical, 11)
                            .background(design.preset == option ? Color(hex: 0x2e4a74) : Color.white.opacity(0.09),
                                        in: Capsule())
                            .overlay(Capsule().stroke(design.preset == option ? Color.white.opacity(0.65) : Color.clear))
                        }
                    }
                }
            }
        }
    }

    private var textSection: some View {
        VStack(alignment: .leading, spacing: 13) {
            sectionHeading("카드 문구")
            field("브랜드", text: $design.bankName)
            field("제목", text: $design.headline)
            field("서브 타이틀", text: $design.subtitle)
            field("하단 문구", text: $design.footer)
            Text("실제 카드번호·이름·보안코드는 입력하지 마.")
                .font(.caption2).foregroundStyle(.secondary)
        }
    }

    private var imageSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading("배경 이미지")
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Label(photo == nil ? "사진 불러오기" : "배경 이미지 변경", systemImage: "photo.on.rectangle")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
            }
            .buttonStyle(.bordered)
            Button {
                showingFileImporter = true
            } label: {
                Label("파일 앱에서 PNG/JPG 불러오기", systemImage: "folder")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.bordered)
            if design.preset != .custom {
                slider("사진 투명도", value: $design.imageOpacity, range: 0...1)
            } else {
                Text("내 이미지는 카드 전체에 불투명하게 적용돼.")
                    .font(.caption2).foregroundStyle(.secondary)
            }
            if design.preset == .custom {
                Picker("이미지 맞춤", selection: Binding(get: { design.fitEntireImage ?? false }, set: { design.fitEntireImage = $0 })) {
                    Text("꽉 채우기").tag(false)
                    Text("전체 보기").tag(true)
                }.pickerStyle(.segmented)
            }
            slider("확대", value: $design.imageScale, range: 1...2.4)
            if photo != nil {
                HStack {
                    Text("사진 위치")
                    Spacer()
                    Button("초기화") {
                        design.imageOffsetX = 0
                        design.imageOffsetY = 0
                    }.font(.caption)
                }.font(.subheadline)
                slider("가로", value: $design.imageOffsetX, range: -500...500)
                slider("세로", value: $design.imageOffsetY, range: -350...350)
                Button("사진 제거", role: .destructive) {
                    photo = nil; selectedPhoto = nil
                    if design.preset == .custom { design.preset = .gold }
                    try? FileManager.default.removeItem(at: artworkFile)
                }
                    .font(.caption)
            }
        }
    }

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeading("장식")
            Toggle("카드 칩", isOn: $design.showsChip)
            Toggle("프리미엄 엠블럼", isOn: $design.showsEmblem)
        }
        .tint(Color(hex: 0x8eb5fd))
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("적용 엔진 미포함", systemImage: "lock.shield")
                .font(.subheadline.weight(.bold))
            Text("이 앱은 디자인을 만들고 PNG로 내보내지만, iOS 27.2의 보호된 Apple Wallet 파일을 변경하지 않아. worse_query가 해당 Wallet 경로에 접근한다는 사실도 확인되지 않았어.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0x233047), in: RoundedRectangle(cornerRadius: 13))
    }

    private func sectionHeading(_ text: String) -> some View {
        Text(text).font(.headline.weight(.bold))
    }
    private func field(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            TextField(title, text: text)
                .textInputAutocapitalization(.characters)
                .padding(12)
                .background(Color.white.opacity(0.075), in: RoundedRectangle(cornerRadius: 10))
        }
    }
    private func slider(_ title: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text(String(format: "%.2f", value.wrappedValue))
                    .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
            }
            .font(.subheadline)
            Slider(value: value, in: range).accessibilityLabel(title)
        }
    }
    private var artworkFile: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("walletskinlab-artwork.png")
    }

    private func previewImage(_ source: CGImageSource) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: 3840
        ]
        guard let bitmap = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }
        return UIImage(cgImage: bitmap)
    }

    private func setCustomPhoto(_ image: UIImage) {
        photo = image
        design.preset = .custom
        design.imageOpacity = 1
        design.fitEntireImage = false
        design.imageScale = 1
        design.imageOffsetX = 0
        design.imageOffsetY = 0
        design.bankName = ""; design.headline = ""; design.subtitle = ""; design.footer = ""
        do {
            try FileManager.default.createDirectory(
                at: artworkFile.deletingLastPathComponent(),
                withIntermediateDirectories: true)
            guard let png = image.pngData() else { throw CocoaError(.fileWriteUnknown) }
            try png.write(to: artworkFile, options: .atomic)
        } catch {
            alertText = "이미지는 불러왔지만 앱에 저장하지 못했어: \(error.localizedDescription)"
        }
    }

    private func loadDesign() {
        if let data = UserDefaults.standard.data(forKey: "design"),
           let stored = try? JSONDecoder().decode(CardDesign.self, from: data) {
            design = stored
        }
        if let saved = UIImage(contentsOfFile: artworkFile.path) {
            photo = saved
        } else if design.preset == .custom {
            design.preset = .gold
        }
    }
    @MainActor private func exportPNG() {
        let renderer = ImageRenderer(content:
            CardArtworkView(design: design, photo: photo)
                .frame(width: 1536, height: 969))
        renderer.scale = 1
        guard let data = renderer.uiImage?.pngData() else {
            alertText = "PNG 이미지 생성에 실패했어. 다시 시도해 줘."
            return
        }
        do {
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("WalletSkinLab-\(UUID().uuidString).png")
            try data.write(to: url, options: .atomic)
            exportItem = ExportItem(url: url)
        } catch {
            alertText = "파일을 저장하지 못했어: \(error.localizedDescription)"
        }
    }
}

private struct ExportItem: Identifiable {
    let id = UUID()
    let url: URL
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
