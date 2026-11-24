import SwiftUI
import UIKit

/// Renders exactly the same artwork for the on-screen preview and 1536×969 PNG export.
/// This view NEVER reads or modifies Apple Wallet or payment-card files.
struct CardArtworkView: View {
    let design: CardDesign
    let photo: UIImage?

    var body: some View {
        GeometryReader { geometry in
            let scale = geometry.size.width / 1536
            let accent = design.preset.accent
            ZStack {
                if design.preset == .gold || design.preset == .premiumBlack || design.preset == .custom {
                    if design.preset == .custom { Color(hex: 0x0b0f16) } else {
                    Image(design.preset == .gold ? "CenturionGold" : "PremiumBlack")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                    }
                    if let photo, design.preset == .custom {
                        let box = geometry.size
                        let fitting = design.fitEntireImage == true
                        let ratio = fitting ? min(box.width / photo.size.width, box.height / photo.size.height)
                                            : max(box.width / photo.size.width, box.height / photo.size.height)
                        let width = photo.size.width * ratio * design.imageScale
                        let height = photo.size.height * ratio * design.imageScale
                        let limitX = max(0, (width - box.width) / 2)
                        let limitY = max(0, (height - box.height) / 2)
                        let dx = design.imageOffsetX * scale
                        let dy = design.imageOffsetY * scale
                        Image(uiImage: photo).resizable()
                            .frame(width: width, height: height)
                            .position(x: box.width / 2 + (fitting ? dx : min(limitX, max(-limitX, dx))),
                                      y: box.height / 2 + (fitting ? dy : min(limitY, max(-limitY, dy))))
                    }
                    VStack(alignment: .leading, spacing: 12 * scale) {
                        if !design.bankName.isEmpty { Text(design.bankName.uppercased()).font(.system(size: 46 * scale, weight: .bold)) }
                        Spacer()
                        if !design.headline.isEmpty { Text(design.headline.uppercased()).font(.system(size: 48 * scale, weight: .heavy)) }
                        if !design.subtitle.isEmpty { Text(design.subtitle.uppercased()).font(.system(size: 30 * scale, weight: .medium)) }
                        if !design.footer.isEmpty { Text(design.footer.uppercased()).font(.system(size: 24 * scale)) }
                    }
                    .foregroundStyle(design.preset == .gold ? Color(hex: 0x24190f) : .white)
                    .shadow(color: .black.opacity(0.6), radius: 6)
                    .padding(.horizontal, 100 * scale)
                    .padding(.vertical, 100 * scale)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                } else {
                LinearGradient(colors: design.preset.colors,
                               startPoint: .topLeading, endPoint: .bottomTrailing)

                if let photo {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .scaleEffect(design.imageScale)
                        .offset(x: design.imageOffsetX * scale,
                                y: design.imageOffsetY * scale)
                        .opacity(design.imageOpacity)
                        .clipped()
                }

                LinearGradient(colors: [.white.opacity(0.08), .clear, .black.opacity(0.25)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)

                Canvas { context, size in
                    for index in 0..<10 {
                        let shift = CGFloat(index) * 115 * scale
                        var path = Path()
                        path.move(to: CGPoint(x: 740 * scale + shift, y: -100 * scale))
                        path.addLine(to: CGPoint(x: 115 * scale + shift,
                                                 y: size.height + 200 * scale))
                        context.stroke(path, with: .color(accent.opacity(0.14)),
                                       lineWidth: max(0.4, 1.6 * scale))
                    }
                }

                if design.showsEmblem {
                    PremiumEmblem(accent: accent)
                        .frame(width: 515 * scale, height: 515 * scale)
                        .position(x: 1185 * scale, y: 510 * scale)
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(design.bankName.uppercased())
                        .font(.system(size: 49 * scale, weight: .bold, design: .rounded))
                        .tracking(3 * scale)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Spacer(minLength: 0)

                    if design.showsChip {
                        DecorativeChip(accent: accent)
                            .frame(width: 155 * scale, height: 120 * scale)
                    }

                    Spacer(minLength: 0)

                    Text(design.headline.uppercased())
                        .font(.system(size: 95 * scale, weight: .heavy, design: .rounded))
                        .tracking(2 * scale)
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                    Text(design.subtitle.uppercased())
                        .font(.system(size: 30 * scale, weight: .medium))
                        .tracking(4 * scale)
                        .foregroundStyle(accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .padding(.top, 8 * scale)
                    Rectangle()
                        .fill(accent.opacity(0.7))
                        .frame(width: 230 * scale, height: max(1, 3 * scale))
                        .padding(.top, 88 * scale)
                    Text(design.footer.uppercased())
                        .font(.system(size: 27 * scale, weight: .medium))
                        .tracking(1.8 * scale)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                        .padding(.top, 26 * scale)
                }
                .foregroundStyle(design.preset.foreground)
                .padding(.horizontal, 87 * scale)
                .padding(.vertical, 76 * scale)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipShape(RoundedRectangle(cornerRadius: 55 * scale, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 55 * scale, style: .continuous)
                .stroke(accent.opacity(0.4), lineWidth: max(0.5, 2 * scale)))
        }
        .aspectRatio(1536.0 / 969.0, contentMode: .fit)
    }
}

private struct DecorativeChip: View {
    let accent: Color
    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            ZStack {
                RoundedRectangle(cornerRadius: w * 0.12)
                    .fill(accent.opacity(0.82))
                    .overlay(RoundedRectangle(cornerRadius: w * 0.12)
                        .stroke(.black.opacity(0.45), lineWidth: max(0.5, w * 0.03)))
                Path { path in
                    path.move(to: CGPoint(x: w * 0.33, y: 0))
                    path.addLine(to: CGPoint(x: w * 0.33, y: h))
                    path.move(to: CGPoint(x: w * 0.67, y: 0))
                    path.addLine(to: CGPoint(x: w * 0.67, y: h))
                    path.move(to: CGPoint(x: 0, y: h * 0.50))
                    path.addLine(to: CGPoint(x: w, y: h * 0.50))
                }.stroke(.black.opacity(0.38), lineWidth: max(0.5, w * 0.023))
            }
        }
    }
}

private struct PremiumEmblem: View {
    let accent: Color
    var body: some View {
        ZStack {
            Circle().stroke(accent.opacity(0.62), lineWidth: 8)
            Circle().stroke(accent.opacity(0.6), lineWidth: 2).padding(36)
            Circle().stroke(accent.opacity(0.34), lineWidth: 3).padding(77)
            Image(systemName: "moon.stars")
                .resizable().scaledToFit().padding(150)
                .foregroundStyle(accent.opacity(0.75))
        }
    }
}
