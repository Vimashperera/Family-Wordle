import SwiftUI

/// Living-room palette. Dark is the tvOS default: night-blue walls, lamp-gold type,
/// and tile colors bright enough to read from the couch. Light mode keeps the same
/// relationships with deeper tile inks so a bright room still works.
struct Palette {
    var background: Color
    var surface: Color
    var surfaceStroke: Color
    var text: Color
    var textSecondary: Color
    var gold: Color
    var correct: Color
    var present: Color
    var absent: Color
    var onBrightTile: Color
    var onAbsentTile: Color
    var emptyFill: Color
    var emptyStroke: Color
    var keyFill: Color
    var danger: Color
    var wood: Color
    var woodInk: Color
    var scrim: Color

    static func resolve(_ scheme: ColorScheme) -> Palette {
        scheme == .dark ? .dark : .light
    }

    static let dark = Palette(
        background: Color(hex: 0x071018),
        surface: Color(hex: 0x162336),
        surfaceStroke: Color(hex: 0x2C3E56),
        text: Color(hex: 0xF7F4EC),
        textSecondary: Color(hex: 0xC5D0DE),
        gold: Color(hex: 0xF0C56E),
        correct: Color(hex: 0x3DDC84),
        present: Color(hex: 0xF0C14A),
        absent: Color(hex: 0x3C4A5E),
        onBrightTile: Color(hex: 0x102018),
        onAbsentTile: Color(hex: 0xF7F4EC),
        emptyFill: Color(hex: 0x0E1826),
        emptyStroke: Color(hex: 0x31445C),
        keyFill: Color(hex: 0x24344A),
        danger: Color(hex: 0xFF8B7B),
        wood: Color(hex: 0xF3E0B8),
        woodInk: Color(hex: 0x2C241C),
        scrim: Color.black.opacity(0.62)
    )

    static let light = Palette(
        background: Color(hex: 0xE7EEF6),
        surface: Color(hex: 0xFFFFFF),
        surfaceStroke: Color(hex: 0xC9D5E2),
        text: Color(hex: 0x122033),
        textSecondary: Color(hex: 0x4E6074),
        gold: Color(hex: 0x8A5A10),
        correct: Color(hex: 0x1B8F4E),
        present: Color(hex: 0xC89212),
        absent: Color(hex: 0x5C6B7A),
        onBrightTile: Color.white,
        onAbsentTile: Color.white,
        emptyFill: Color(hex: 0xF7FAFD),
        emptyStroke: Color(hex: 0xC5D0DC),
        keyFill: Color(hex: 0xE1E8F0),
        danger: Color(hex: 0xB42318),
        wood: Color(hex: 0xE7C98A),
        woodInk: Color(hex: 0x2C241C),
        scrim: Color(hex: 0x122033).opacity(0.45)
    )
}

/// Six couch colors. Index order is the assignment order in setup.
enum PlayerColor {
    static let names = ["Coral", "Sky", "Mint", "Amber", "Violet", "Rose"]

    static let colors: [Color] = [
        Color(hex: 0xFF6B5C),
        Color(hex: 0x5EB0FF),
        Color(hex: 0x3DDC97),
        Color(hex: 0xFFC14D),
        Color(hex: 0xB48CFF),
        Color(hex: 0xFF8AB8)
    ]

    static func color(_ index: Int) -> Color {
        colors[index % colors.count]
    }

    static func name(_ index: Int) -> String {
        names[index % names.count]
    }
}

extension Color {
    init(hex: UInt32) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}

private struct PaletteKey: EnvironmentKey {
    static let defaultValue = Palette.dark
}

extension EnvironmentValues {
    var palette: Palette {
        get { self[PaletteKey.self] }
        set { self[PaletteKey.self] = newValue }
    }
}

extension View {
    /// Injects the palette and an in-memory store so Xcode previews render the TV UI.
    func previewPalette(_ scheme: ColorScheme = .dark) -> some View {
        let palette = Palette.resolve(scheme)
        return self
            .environment(\.palette, palette)
            .environmentObject(PersistenceStore.preview())
            .preferredColorScheme(scheme)
            .background(palette.background)
    }
}
