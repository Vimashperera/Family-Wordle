import SwiftUI

struct PlayerSetupView: View {
    let mode: GameMode
    var onBack: () -> Void
    var onStart: (_ participants: [Participant], _ daily: Bool) -> Void

    @Environment(\.palette) private var palette
    @EnvironmentObject private var store: PersistenceStore
    @FocusState private var focus: SetupFocus?

    @State private var daily = true
    @State private var playerCount = 3
    @State private var names = Array(repeating: "", count: GameRules.maxPlayers)
    @State private var teamNames = ["", ""]
    @State private var didLoad = false

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            HStack {
                Button(action: onBack) {
                    Label("Menu", systemImage: "chevron.backward")
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.card)
                .focused($focus, equals: .back)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(mode.title)
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.text)
                Text(mode.setupDetail)
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
            }

            HStack(spacing: 20) {
                puzzleChoice(
                    title: "Today's word",
                    subtitle: "Same puzzle for everyone today",
                    selected: daily,
                    focus: .daily
                ) {
                    daily = true
                    store.settings.preferDailyWord = true
                }
                puzzleChoice(
                    title: "Practice word",
                    subtitle: "A random word, just for this round",
                    selected: !daily,
                    focus: .practice
                ) {
                    daily = false
                    store.settings.preferDailyWord = false
                }
            }

            if mode == .family {
                familyEditor
            } else if mode == .team {
                teamEditor
            }

            HStack {
                Button(action: start) {
                    Text("Start game")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .padding(.horizontal, 42)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.card)
                .focused($focus, equals: .start)

                if mode == .family {
                    Text("Move up to rename players.")
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundStyle(palette.textSecondary)
                        .padding(.leading, 12)
                }
                Spacer()
            }
        }
        .padding(.horizontal, 56)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .defaultFocus($focus, .start)
        .onAppear(perform: load)
    }

    private var familyEditor: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 18) {
                Text("Players")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.text)
                countButton(symbol: "minus", focus: .minus, enabled: playerCount > GameRules.minPlayers) {
                    playerCount -= 1
                    store.settings.familyPlayerCount = playerCount
                }
                Text("\(playerCount)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .frame(minWidth: 36)
                    .foregroundStyle(palette.text)
                countButton(symbol: "plus", focus: .plus, enabled: playerCount < GameRules.maxPlayers) {
                    playerCount += 1
                    store.settings.familyPlayerCount = playerCount
                }
            }

            let split = (playerCount + 1) / 2
            HStack(alignment: .top, spacing: 28) {
                nameColumn(Array(0..<split))
                if playerCount > split {
                    nameColumn(Array(split..<playerCount))
                }
            }
        }
    }

    private var teamEditor: some View {
        HStack(spacing: 28) {
            teamField(index: 0, placeholder: "Parents")
            teamField(index: 1, placeholder: "Kids")
        }
    }

    private func nameColumn(_ indices: [Int]) -> some View {
        VStack(spacing: 12) {
            ForEach(indices, id: \.self) { index in
                nameField(
                    title: "Player \(index + 1)",
                    text: $names[index],
                    colorIndex: index,
                    focus: .name(index)
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func teamField(index: Int, placeholder: String) -> some View {
        nameField(
            title: placeholder,
            text: $teamNames[index],
            colorIndex: index,
            focus: .team(index)
        )
    }

    private func nameField(
        title: String,
        text: Binding<String>,
        colorIndex: Int,
        focus: SetupFocus
    ) -> some View {
        HStack(spacing: 14) {
            PlayerSwatch(colorIndex: colorIndex, size: 32)
            TextField(title, text: text)
                .focused($focus, equals: focus)
                .textInputAutocapitalization(.words)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .foregroundStyle(palette.text)
                .padding(.horizontal, 16)
                .frame(height: 64)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(palette.background)
                )
                .onChange(of: text.wrappedValue) { _, newValue in
                    if newValue.count > 14 {
                        text.wrappedValue = String(newValue.prefix(14))
                    }
                }
        }
        .accessibilityLabel("\(title), \(PlayerColor.name(colorIndex))")
    }

    private func puzzleChoice(
        title: String,
        subtitle: String,
        selected: Bool,
        focus: SetupFocus,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                    Spacer()
                    if selected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(palette.gold)
                    }
                }
                Text(subtitle)
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
            }
            .foregroundStyle(palette.text)
            .padding(22)
            .frame(width: 460, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(selected ? palette.gold.opacity(0.16) : palette.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(selected ? palette.gold : palette.surfaceStroke, lineWidth: selected ? 4 : 2)
            )
        }
        .buttonStyle(KeyButtonStyle())
        .focused($focus, equals: focus)
        .focusEffectDisabled()
    }

    private func countButton(
        symbol: String,
        focus: SetupFocus,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 28, weight: .bold))
                .frame(width: 64, height: 64)
        }
        .buttonStyle(.card)
        .focused($focus, equals: focus)
        .disabled(!enabled)
    }

    private func load() {
        guard !didLoad else { return }
        didLoad = true
        daily = store.settings.preferDailyWord
        playerCount = store.settings.familyPlayerCount
        for (index, name) in store.savedFamilyNames.enumerated() where index < names.count {
            names[index] = name
        }
        if store.savedTeamNames.indices.contains(0) { teamNames[0] = store.savedTeamNames[0] }
        if store.savedTeamNames.indices.contains(1) { teamNames[1] = store.savedTeamNames[1] }
    }

    private func start() {
        let people: [Participant]
        switch mode {
        case .solo:
            people = [Participant(name: "You", colorIndex: 0)]
        case .family:
            people = (0..<playerCount).map { index in
                Participant(
                    name: cleaned(names[index], fallback: "Player \(index + 1)"),
                    colorIndex: index
                )
            }
            store.saveFamilyNames(people.map(\.name))
            store.settings.familyPlayerCount = playerCount
        case .team:
            people = [
                Participant(name: cleaned(teamNames[0], fallback: "Parents"), colorIndex: 0),
                Participant(name: cleaned(teamNames[1], fallback: "Kids"), colorIndex: 1)
            ]
            store.saveTeamNames(people.map(\.name))
        }
        onStart(people, daily)
    }

    private func cleaned(_ raw: String, fallback: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : String(trimmed.prefix(14))
    }
}

private enum SetupFocus: Hashable {
    case back
    case daily
    case practice
    case minus
    case plus
    case name(Int)
    case team(Int)
    case start
}

#Preview {
    PlayerSetupView(mode: .family, onBack: {}, onStart: { _, _ in })
        .previewPalette()
}
