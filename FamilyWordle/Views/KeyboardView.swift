import SwiftUI

struct KeyboardView: View {
    let keyStates: [Character: TileFeedback]
    /// False while tiles are flipping. Keys stay on screen but ignore clicks.
    let interactive: Bool
    /// False during handoff and results, so the remote cannot focus a covered keyboard.
    let focusable: Bool
    let keyHeight: CGFloat
    var focus: FocusState<GameFocus?>.Binding
    var onLetter: (Character) -> Void
    var onDelete: () -> Void
    var onGuess: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(KeyboardKey.rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 8) {
                    ForEach(row) { key in
                        keyButton(key)
                    }
                }
            }
        }
        .focusSection()
        .opacity(interactive ? 1 : 0.55)
        .animation(.easeOut(duration: 0.2), value: interactive)
    }

    private func keyButton(_ key: KeyboardKey) -> some View {
        Button {
            guard interactive else { return }
            switch key {
            case .letter(let character): onLetter(character)
            case .delete: onDelete()
            case .guess: onGuess()
            }
        } label: {
            KeyCap(
                key: key,
                feedback: feedback(for: key),
                height: keyHeight
            )
        }
        .buttonStyle(KeyButtonStyle())
        .focused(focus, equals: .key(key))
        .disabled(!focusable)
        .focusEffectDisabled()
        .accessibilityLabel(accessibilityLabel(for: key))
    }

    private func feedback(for key: KeyboardKey) -> TileFeedback? {
        guard case .letter(let character) = key else { return nil }
        return keyStates[character]
    }

    private func accessibilityLabel(for key: KeyboardKey) -> String {
        switch key {
        case .letter(let character): "Letter \(character)"
        case .delete: "Delete"
        case .guess: "Guess"
        }
    }
}

struct KeyCap: View {
    let key: KeyboardKey
    let feedback: TileFeedback?
    let height: CGFloat

    @Environment(\.palette) private var palette
    @Environment(\.isFocused) private var isFocused

    var body: some View {
        label
            .font(.system(size: key == .guess || key == .delete ? 24 : height * 0.42, weight: .bold, design: .rounded))
            .foregroundStyle(isFocused ? Color.black : foreground)
            .frame(width: width, height: height)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isFocused ? Color.white : background)
            )
    }

    @ViewBuilder
    private var label: some View {
        switch key {
        case .letter(let character):
            Text(String(character))
        case .guess:
            Text("Guess")
        case .delete:
            Image(systemName: "delete.left.fill")
        }
    }

    private var width: CGFloat {
        switch key {
        case .letter: height * 1.08
        case .guess, .delete: height * 1.85
        }
    }

    private var background: Color {
        switch feedback {
        case .correct: palette.correct
        case .present: palette.present
        case .absent: palette.absent
        case .empty, nil: palette.keyFill
        }
    }

    private var foreground: Color {
        switch feedback {
        case .correct, .present: palette.onBrightTile
        case .absent: palette.onAbsentTile
        case .empty, nil: palette.text
        }
    }
}

/// Scale and lift without the system halo, which is too heavy on a dense keyboard.
struct KeyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        KeyButtonBody(configuration: configuration)
    }

    private struct KeyButtonBody: View {
        @Environment(\.isFocused) private var isFocused
        let configuration: ButtonStyleConfiguration

        var body: some View {
            configuration.label
                .scaleEffect(isFocused ? 1.12 : 1)
                .shadow(color: .black.opacity(isFocused ? 0.35 : 0), radius: isFocused ? 16 : 0, y: 8)
                .animation(.easeOut(duration: 0.14), value: isFocused)
        }
    }
}
