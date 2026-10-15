import SwiftUI

struct HowToPlayView: View {
    var onBack: () -> Void

    @Environment(\.palette) private var palette
    @FocusState private var menuFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            HStack {
                Button(action: onBack) {
                    Label("Menu", systemImage: "chevron.backward")
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.card)
                .focused($menuFocused)
                Spacer()
            }

            Text("How to play")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(palette.text)

            Text("Each guess is a five-letter word. Tiles change color after you click Guess.")
                .font(.system(size: 30, weight: .medium, design: .rounded))
                .foregroundStyle(palette.textSecondary)

            HStack(alignment: .top, spacing: 36) {
                ruleTile(letter: "A", feedback: .correct, title: "Right spot", detail: "This letter is in the word, and it is in the right place.")
                ruleTile(letter: "A", feedback: .present, title: "Wrong spot", detail: "This letter is in the word, but not in this place.")
                ruleTile(letter: "A", feedback: .absent, title: "Not in the word", detail: "This letter is not in the word at all.")
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("You get six guesses. In family mode and team mode, everyone shares those six rows.")
                Text("After a guess, pass the remote when the screen asks. The next player continues the same puzzle.")
                Text("Today's word is the same for every household on the same day. A practice word is only for fun.")
            }
            .font(.system(size: 28, weight: .medium, design: .rounded))
            .foregroundStyle(palette.text)
            .frame(maxWidth: 1200, alignment: .leading)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 56)
        .padding(.vertical, 28)
        .defaultFocus($menuFocused, true)
    }

    private func ruleTile(letter: Character, feedback: TileFeedback, title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            TileView(
                letter: letter,
                feedback: feedback,
                isSubmitted: true,
                flipDelay: 0,
                accent: palette.gold,
                isActive: false,
                tileSize: 108,
                startsRevealed: true
            )
            Text(title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(palette.text)
            Text(detail)
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundStyle(palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(palette.surface)
        )
    }
}

#Preview {
    HowToPlayView(onBack: {})
        .previewPalette()
}
