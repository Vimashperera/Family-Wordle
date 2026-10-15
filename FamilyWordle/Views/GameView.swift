import SwiftUI

/// Focus targets on the game screen. The keyboard, the handoff button, and the
/// results actions share one focus state so the remote never lands on a hidden control.
enum GameFocus: Hashable {
    case menu
    case key(KeyboardKey)
    case ready
    case practiceAgain
    case mainMenu
}

/// The board, the keyboard, and the two full-screen beats between them:
/// pass-the-remote, then results.
struct GameView: View {
    @ObservedObject var model: GameViewModel
    var onMenu: () -> Void

    @Environment(\.palette) private var palette
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var focus: GameFocus?
    @Namespace private var turnNamespace
    @State private var shakeTravels: CGFloat = 0

    var body: some View {
        ZStack {
            palette.background.ignoresSafeArea()
            glow.allowsHitTesting(false)

            HStack(spacing: 0) {
                accentRail
                boardColumn
                ScoreboardView(model: model, namespace: turnNamespace)
                    .frame(width: 400)
                    .padding(.trailing, 28)
            }

            if model.phase == .handoff {
                PassRemoteView(
                    participant: model.current,
                    namespace: turnNamespace,
                    focus: $focus,
                    onReady: { model.confirmHandoff() },
                    onMenu: onMenu
                )
                .transition(.opacity)
            }

            if model.phase == .results {
                ResultsView(
                    model: model,
                    focus: $focus,
                    onPractice: { model.startRematch() },
                    onMenu: onMenu
                )
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .defaultFocus($focus, preferredFocus)
        .onAppear { moveFocus(for: model.phase) }
        .onChange(of: model.phase) { _, phase in
            moveFocus(for: phase)
        }
        .onChange(of: model.roundID) { _, _ in
            moveFocus(for: model.phase)
        }
        .onChange(of: model.shakeToken) { _, _ in
            guard !reduceMotion else { return }
            withAnimation(.linear(duration: 0.42)) {
                shakeTravels += 1
            }
        }
        .onKeyPress(phases: .down) { press in
            handleKey(press)
        }
    }

    private var glow: some View {
        RadialGradient(
            colors: [
                accent.opacity(colorScheme == .dark ? 0.32 : 0.16),
                .clear
            ],
            center: UnitPoint(x: 0.4, y: 0.4),
            startRadius: 20,
            endRadius: 720
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.5), value: model.currentIndex)
    }

    private var accentRail: some View {
        accent
            .frame(width: 12)
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.45), value: model.currentIndex)
    }

    private var boardColumn: some View {
        GeometryReader { proxy in
            let metrics = metrics(in: proxy.size)
            VStack(spacing: 14) {
                header
                WordGridView(
                    rows: model.rows,
                    currentRow: model.currentRow,
                    currentGuess: model.currentGuess,
                    accent: accent,
                    tileSize: metrics.tile,
                    celebrateRow: model.celebrateRow,
                    shakeTravels: shakeTravels
                )
                .id(model.roundID)

                banner

                KeyboardView(
                    keyStates: model.keyStates,
                    interactive: keyboardEnabled,
                    focusable: model.phase == .playing,
                    keyHeight: metrics.key,
                    focus: $focus,
                    onLetter: { model.append($0) },
                    onDelete: { model.deleteLetter() },
                    onGuess: { model.submit() }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }

    private var header: some View {
        HStack(spacing: 20) {
            Button(action: onMenu) {
                Label("Menu", systemImage: "chevron.backward")
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.card)
            .focused($focus, equals: .menu)
            .disabled(model.phase != .playing)

            Text(model.turnTitle)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(model.mode == .solo ? palette.text : accent)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Spacer(minLength: 12)

            Text("\(model.guessesRemaining) left")
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundStyle(palette.textSecondary)
                .accessibilityLabel("\(model.guessesRemaining) guesses left")
        }
    }

    private var banner: some View {
        Text(model.banner ?? " ")
            .font(.system(size: 28, weight: .semibold, design: .rounded))
            .foregroundStyle(palette.danger)
            .frame(height: 36)
            .accessibilityHidden(model.banner == nil)
    }

    private var accent: Color {
        model.mode == .solo ? palette.gold : PlayerColor.color(model.current.colorIndex)
    }

    private var keyboardEnabled: Bool {
        model.phase == .playing && !model.isRevealing
    }

    private var preferredFocus: GameFocus {
        switch model.phase {
        case .handoff: .ready
        case .playing: .key(.letter("Q"))
        case .results: .practiceAgain
        }
    }

    /// Tiles grow to fill the space above a three-row keyboard, and stop before
    /// they crowd the safe area. A 55-inch screen gets large tiles; a tight height does not clip.
    private func metrics(in size: CGSize) -> (tile: CGFloat, key: CGFloat) {
        let key: CGFloat = 66
        let keyboard = key * 3 + 8 * 2
        let chrome: CGFloat = 78 + 36 + 14 * 3
        // Leave a little unused height so the keyboard stays inside the TV safe area.
        let gridHeight = size.height - keyboard - chrome - 16
        let tile = min(112, max(72, (gridHeight - 8 * 5) / 6))
        return (tile, key)
    }

    private func moveFocus(for phase: GamePhase) {
        switch phase {
        case .handoff:
            focus = .ready
        case .playing:
            focus = .key(.letter("Q"))
        case .results:
            focus = .practiceAgain
        }
    }

    /// Mac keyboard support for the simulator. The remote still drives focus;
    /// letter keys type into the current row, and delete removes one.
    private func handleKey(_ press: KeyPress) -> KeyPress.Result {
        guard keyboardEnabled else { return .ignored }
        if press.key == .delete || press.key == .deleteForward {
            model.deleteLetter()
            return .handled
        }
        let characters = press.characters.uppercased()
        guard characters.count == 1, let character = characters.first, character.isLetter else {
            return .ignored
        }
        model.append(character)
        return .handled
    }
}

#Preview {
    GameView(model: .previewFamily(), onMenu: {})
        .previewPalette()
}
