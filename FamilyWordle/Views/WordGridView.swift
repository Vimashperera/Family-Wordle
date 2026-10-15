import SwiftUI

struct WordGridView: View {
    let rows: [BoardRow]
    let currentRow: Int
    let currentGuess: String
    let accent: Color
    let tileSize: CGFloat
    let celebrateRow: Int?
    let shakeTravels: CGFloat

    var body: some View {
        VStack(spacing: 8) {
            ForEach(rows) { row in
                HStack(spacing: 8) {
                    ForEach(0..<GameRules.wordLength, id: \.self) { column in
                        TileView(
                            letter: glyph(row: row, column: column),
                            feedback: row.isSubmitted ? row.feedback[column] : .empty,
                            isSubmitted: row.isSubmitted,
                            flipDelay: Double(column) * 0.12,
                            accent: accent,
                            isActive: row.index == currentRow && !row.isSubmitted,
                            tileSize: tileSize,
                            celebrate: celebrateRow == row.index
                        )
                    }
                }
                .modifier(ShakeEffect(shakes: row.index == currentRow ? shakeTravels : 0))
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func glyph(row: BoardRow, column: Int) -> Character? {
        if row.isSubmitted {
            return column < row.letters.count ? row.letters[column] : nil
        }
        guard row.index == currentRow else { return nil }
        let typed = Array(currentGuess)
        return column < typed.count ? typed[column] : nil
    }
}

/// Horizontal shake used when a guess is too short or not in the word list.
struct ShakeEffect: GeometryEffect {
    var shakes: CGFloat

    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = sin(shakes * .pi * 4) * 16
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
