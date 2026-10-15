import SwiftUI

struct SettingsView: View {
    var onBack: () -> Void

    @Environment(\.palette) private var palette
    @EnvironmentObject private var store: PersistenceStore
    @FocusState private var focus: SettingsFocus?
    @State private var confirmingReset = false
    @State private var didReset = false

    var body: some View {
        HStack(alignment: .top, spacing: 48) {
            controls
                .frame(maxWidth: 760, alignment: .leading)
            stats
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 56)
        .padding(.vertical, 28)
        .defaultFocus($focus, .sound)
        .onChange(of: focus) { _, newValue in
            if newValue != .reset {
                confirmingReset = false
            }
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 26) {
            Button(action: onBack) {
                Label("Menu", systemImage: "chevron.backward")
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.card)
            .focused($focus, equals: .menu)

            Text("Settings")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(palette.text)

            Toggle(isOn: soundBinding) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sound effects")
                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                    Text(store.settings.soundEnabled ? "On" : "Off")
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                        .foregroundStyle(palette.textSecondary)
                }
            }
            .focused($focus, equals: .sound)

            VStack(alignment: .leading, spacing: 12) {
                Text("Family mode players")
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundStyle(palette.text)
                HStack(spacing: 16) {
                    Button {
                        store.settings.familyPlayerCount = max(GameRules.minPlayers, store.settings.familyPlayerCount - 1)
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 28, weight: .bold))
                            .frame(width: 64, height: 64)
                    }
                    .buttonStyle(.card)
                    .focused($focus, equals: .fewer)
                    .disabled(store.settings.familyPlayerCount <= GameRules.minPlayers)

                    Text("\(store.settings.familyPlayerCount)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .frame(minWidth: 40)
                        .foregroundStyle(palette.text)

                    Button {
                        store.settings.familyPlayerCount = min(GameRules.maxPlayers, store.settings.familyPlayerCount + 1)
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .bold))
                            .frame(width: 64, height: 64)
                    }
                    .buttonStyle(.card)
                    .focused($focus, equals: .more)
                    .disabled(store.settings.familyPlayerCount >= GameRules.maxPlayers)
                }
                Text("Used the next time you open family mode. You can still change it there.")
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
            }

            Button(action: reset) {
                Text(confirmingReset ? "Confirm reset" : "Reset stats")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.card)
            .focused($focus, equals: .reset)

            if didReset {
                Text("Stats reset.")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(palette.gold)
            }

            Spacer(minLength: 0)
        }
    }

    private var stats: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("Solo streak")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(palette.text)

            HStack(spacing: 28) {
                statBlock("Played", "\(store.soloStats.played)")
                statBlock("Win rate", "\(store.soloStats.winRate)%")
                statBlock("Streak", "\(store.soloStats.currentStreak)")
                statBlock("Best", "\(store.soloStats.maxStreak)")
            }

            distribution

            Text("Household")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(palette.text)
                .padding(.top, 8)

            if store.rankedRecords.isEmpty {
                Text("Wins land here after a family or team game.")
                    .font(.system(size: 26, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
            } else {
                ForEach(Array(store.rankedRecords.prefix(6).enumerated()), id: \.element.name) { index, entry in
                    HStack(spacing: 16) {
                        Text("\(index + 1)")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(palette.gold)
                            .frame(width: 28, alignment: .leading)
                        Text(entry.name)
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .foregroundStyle(palette.text)
                            .lineLimit(1)
                        Spacer()
                        Text("\(entry.record.points) pts")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(palette.textSecondary)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(palette.surface)
        )
    }

    private var distribution: some View {
        let maxCount = max(store.soloStats.distribution.max() ?? 0, 1)
        return VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<GameRules.maxGuesses, id: \.self) { index in
                let count = store.soloStats.distribution[index]
                HStack(spacing: 12) {
                    Text("\(index + 1)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .frame(width: 20)
                        .foregroundStyle(palette.textSecondary)
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(palette.correct.opacity(count == 0 ? 0.25 : 1))
                        .frame(width: max(10, 280 * CGFloat(count) / CGFloat(maxCount)), height: 16)
                    Spacer(minLength: 0)
                    Text("\(count)")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .frame(width: 36, alignment: .trailing)
                        .foregroundStyle(palette.text)
                }
            }
        }
    }

    private func statBlock(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundStyle(palette.textSecondary)
            Text(value)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(palette.text)
        }
    }

    private var soundBinding: Binding<Bool> {
        Binding(
            get: { store.settings.soundEnabled },
            set: { store.settings.soundEnabled = $0 }
        )
    }

    private func reset() {
        if confirmingReset {
            store.resetStats()
            confirmingReset = false
            didReset = true
        } else {
            confirmingReset = true
            didReset = false
        }
    }
}

private enum SettingsFocus: Hashable {
    case menu
    case sound
    case fewer
    case more
    case reset
}

#Preview {
    SettingsView(onBack: {})
        .previewPalette()
}
