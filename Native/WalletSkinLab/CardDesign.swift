import SwiftUI

struct CardDesign: Codable, Equatable {
    enum Preset: String, Codable, CaseIterable, Identifiable {
        case gold, premiumBlack, custom, obsidian, platinum, midnight, graphite
        var id: String { rawValue }
        var title: String {
            switch self {
            case .gold: return "Centurion Gold"
            case .premiumBlack: return "Premium Black"
            case .custom: return "내 이미지"
            case .obsidian: return "Obsidian"
            case .platinum: return "Platinum"
            case .midnight: return "Midnight"
            case .graphite: return "Graphite"
            }
        }
        var colors: [Color] {
            switch self {
            case .gold: return [Color(hex: 0xf3d486), Color(hex: 0x94713a)]
            case .premiumBlack: return [Color(hex: 0x131923), Color(hex: 0x020407)]
            case .custom: return [.black, Color(hex: 0x0e1119)]
            case .obsidian: return [Color(hex: 0x19232c), Color(hex: 0x030508)]
            case .platinum: return [Color(hex: 0xdce1e6), Color(hex: 0x75808a)]
            case .midnight: return [Color(hex: 0x1a3158), Color(hex: 0x070e20)]
            case .graphite: return [Color(hex: 0x34302c), Color(hex: 0x080807)]
            }
        }
        var accent: Color {
            switch self {
            case .gold: return Color(hex: 0x372813)
            case .premiumBlack: return Color(hex: 0xd4dce8)
            case .custom: return .white
            case .obsidian: return Color(hex: 0xbac6d2)
            case .platinum: return .white
            case .midnight: return Color(hex: 0x9dbbff)
            case .graphite: return Color(hex: 0xd6b786)
            }
        }
        var foreground: Color { (self == .platinum || self == .gold) ? Color(hex: 0x1b2734) : .white }
    }

    var preset: Preset = .gold
    var bankName = ""
    var headline = ""
    var subtitle = ""
    var footer = ""
    var imageOpacity: Double = 0.8
    var fitEntireImage: Bool?
    var imageScale: Double = 1.0
    var imageOffsetX: Double = 0
    var imageOffsetY: Double = 0
    var showsChip = false
    var showsEmblem = false
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: 1
        )
    }
}
