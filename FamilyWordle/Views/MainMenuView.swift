import SwiftUI

struct MainMenuView: View {
    var onSolo: () -> Void
    var onFamily: () -> Void
    var onTeam: () -> Void
    var onHowToPlay: () -> Void
    var onSettings: () -> Void

    @Environment(\.palette) private var palette
    @FocusState private var focus: MenuChoice?

    var body: some View {
        HStack(alignment: .center, spacing: 64) {
            VStack(alignment: .leading, spacing: 28) {
                Text(Date.now, format: .dateTime.weekday(.wide).month(.wide).day())
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                    .foregroundStyle(palette.gold)

                VStack(alignment: .leading, spacing: -4) {
                    Text("Family")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                    Text("Wordle")
                        .font(.system(size: 78, weight: .bold, design: .rounded))
                }
                .foregroundStyle(palette.text)
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(.isHeader)

                Text("One puzzle. Pass the remote.")
                    .font(.system(size: 32, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.textSecondary)

                VStack(spacing: 14) {
                    menuButton(
                        .solo,
                        title: "Solo",
                        subtitle: "A quiet puzzle for one",
                        symbol: "person.fill",
                        action: onSolo
                    )
                    menuButton(
                        .family,
                        title: "Family mode",
                        subtitle: "Share a grid, pass the remote",
                        symbol: "person.3.fill",
                        action: onFamily
                    )
                    menuButton(
                        .team,
                        title: "Team mode",
                        subtitle: "Two sides, one word",
                        symbol: "flag.2.crossed.fill",
                        action: onTeam
                    )
                    menuButton(
                        .howTo,
                        title: "How to play",
                        subtitle: "Green, yellow, and gray",
                        symbol: "questionmark.circle.fill",
                        action: onHowToPlay
                    )
                    menuButton(
                        .settings,
                        title: "Settings",
                        subtitle: "Sound, players, and stats",
                        symbol: "gearshape.fill",
                        action: onSettings
                    )
                }
                .focusSection()
                .padding(.top, 8)
            }
            .frame(maxWidth: 760, alignment: .leading)

            Spacer(minLength: 20)

            MarqueeTiles()
                .padding(.trailing, 24)
        }
        .padding(.horizontal, 36)
        .padding(.vertical, 20)
        .defaultFocus($focus, .solo)
    }

    private func menuButton(
        _ choice: MenuChoice,
        title: String,
        subtitle: String,
        symbol: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 22) {
                Image(systemName: symbol)
                    .font(.system(size: 32, weight: .semibold))
                    .frame(width: 48)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                    Text(subtitle)
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .frame(width: 620, alignment: .leading)
        }
        .buttonStyle(.card)
        .focused($focus, equals: choice)
    }
}

private enum MenuChoice: Hashable {
    case solo, family, team, howTo, settings
}

/// Wooden letter tiles on the right of the menu. They change word slowly,
/// which is the only motion on this screen.
private struct MarqueeTiles: View {
    private let words = ["HOUSE", "SMILE", "PARTY", "MOVIE", "BREAD"]
    private let tilts: [Double] = [-5, 3.5, -2, 4, -3.5]

    @Environment(\.palette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var index = 0

    var body: some View {
        let letters = Array(words[index])
        HStack(spacing: 16) {
            ForEach(0..<letters.count, id: \.self) { column in
                Text(String(letters[column]))
                    .font(.system(size: 68, weight: .heavy, design: .rounded))
                    .foregroundStyle(palette.woodInk)
                    .frame(width: 118, height: 118)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(palette.wood)
                    )
                    .rotationEffect(.degrees(tilts[column]))
                    .shadow(color: .black.opacity(0.28), radius: 18, y: 14)
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.45), value: index)
        .accessibilityLabel("Letter tiles")
        .task {
            guard !reduceMotion else { return }
            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(2.6))
                } catch {
                    return
                }
                guard !Task.isCancelled else { return }
                index = (index + 1) % words.count
            }
        }
    }
}

#Preview {
    MainMenuView(onSolo: {}, onFamily: {}, onTeam: {}, onHowToPlay: {}, onSettings: {})
        .previewPalette()
}
