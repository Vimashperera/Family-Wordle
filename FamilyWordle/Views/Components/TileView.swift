import SwiftUI

/// A single board tile. Submitted tiles flip halfway, swap to their color, then land.
/// The delay is per column so the row reads left to right, the way a couch watches it.
struct TileView: View {
    let letter: Character?
    let feedback: TileFeedback
    let isSubmitted: Bool
    let flipDelay: Double
    let accent: Color
    let isActive: Bool
    let tileSize: CGFloat
    var celebrate: Bool = false
    var startsRevealed: Bool = false

    @Environment(\.palette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var angle: Double
    @State private var showFeedback: Bool

    init(
        letter: Character?,
        feedback: TileFeedback,
        isSubmitted: Bool,
        flipDelay: Double,
        accent: Color,
        isActive: Bool,
        tileSize: CGFloat,
        celebrate: Bool = false,
        startsRevealed: Bool = false
    ) {
        self.letter = letter
        self.feedback = feedback
        self.isSubmitted = isSubmitted
        self.flipDelay = flipDelay
        self.accent = accent
        self.isActive = isActive
        self.tileSize = tileSize
        self.celebrate = celebrate
        self.startsRevealed = startsRevealed
        _angle = State(initialValue: 0)
        _showFeedback = State(initialValue: startsRevealed)
    }

    var body: some View {
        Text(letter.map { String($0) } ?? "")
            .font(.system(size: tileSize * 0.48, weight: .heavy, design: .rounded))
            .foregroundStyle(textColor)
            .frame(width: tileSize, height: tileSize)
            .background(
                RoundedRectangle(cornerRadius: tileSize * 0.14, style: .continuous)
                    .fill(fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: tileSize * 0.14, style: .continuous)
                    .stroke(stroke, lineWidth: isActive && letter == nil ? 3 : 2)
            )
            .rotation3DEffect(.degrees(angle), axis: (x: 1, y: 0, z: 0), perspective: 0.45)
            .scaleEffect(letter == nil ? 0.98 : 1)
            .offset(y: celebrate && !reduceMotion ? -16 : 0)
            .animation(.spring(response: 0.22, dampingFraction: 0.62), value: letter)
            .animation(
                .spring(response: 0.34, dampingFraction: 0.48).delay(flipDelay),
                value: celebrate
            )
            .accessibilityLabel(accessibilityText)
            .task(id: isSubmitted) {
                await runFlip()
            }
    }

    private var fill: Color {
        guard showFeedback else { return palette.emptyFill }
        switch feedback {
        case .correct: return palette.correct
        case .present: return palette.present
        case .absent: return palette.absent
        case .empty: return palette.emptyFill
        }
    }

    private var textColor: Color {
        guard showFeedback else { return palette.text }
        switch feedback {
        case .correct, .present: return palette.onBrightTile
        case .absent: return palette.onAbsentTile
        case .empty: return palette.text
        }
    }

    private var stroke: Color {
        if isActive && !showFeedback { return accent }
        if showFeedback { return .clear }
        return palette.emptyStroke
    }

    private var accessibilityText: String {
        let glyph = letter.map { String($0) } ?? "Empty"
        guard showFeedback else { return glyph }
        switch feedback {
        case .correct: return "\(glyph), right spot"
        case .present: return "\(glyph), wrong spot"
        case .absent: return "\(glyph), not in the word"
        case .empty: return glyph
        }
    }

    private func runFlip() async {
        guard isSubmitted else {
            angle = 0
            showFeedback = false
            return
        }
        if startsRevealed || reduceMotion {
            showFeedback = true
            angle = 0
            return
        }

        withAnimation(.easeIn(duration: 0.18).delay(flipDelay)) {
            angle = 90
        }
        let milliseconds = Int((flipDelay + 0.18) * 1000)
        do {
            try await Task.sleep(for: .milliseconds(milliseconds))
        } catch {
            return
        }
        guard !Task.isCancelled else { return }
        showFeedback = true
        withAnimation(.easeOut(duration: 0.22)) {
            angle = 0
        }
    }
}
