import SwiftUI

struct PlayerSwatch: View {
    let colorIndex: Int
    var size: CGFloat = 28

    var body: some View {
        Circle()
            .fill(PlayerColor.color(colorIndex))
            .frame(width: size, height: size)
            .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: max(2, size * 0.06)))
            .accessibilityHidden(true)
    }
}

struct ScoreboardView: View {
    @ObservedObject var model: GameViewModel
    var namespace: Namespace.ID

    @Environment(\.palette) private var palette
    @EnvironmentObject private var store: PersistenceStore

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            pill

            if model.mode == .solo {
                soloPanel
            } else {
                Text(model.mode == .team ? "Teams" : "This round")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
                VStack(spacing: 12) {
                    ForEach(Array(model.participants.enumerated()), id: \.element.id) { index, person in
                        playerRow(person, isCurrent: index == model.currentIndex)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(28)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(palette.surface.opacity(0.92))
        )
        .padding(.vertical, 20)
    }

    private var pill: some View {
        Text(model.usesDailyWord ? "Daily word" : "Practice")
            .font(.system(size: 22, weight: .semibold, design: .rounded))
            .foregroundStyle(palette.text)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Capsule().fill(palette.background))
    }

    private var soloPanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            labeledNumber("Guess", value: "\(min(model.currentRow + 1, GameRules.maxGuesses)) of \(GameRules.maxGuesses)")
            if model.usesDailyWord {
                labeledNumber("Streak", value: "\(store.soloStats.currentStreak)")
                labeledNumber("Played", value: "\(store.soloStats.played)")
            } else {
                Text("Practice rounds stay off your streak.")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func labeledNumber(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundStyle(palette.textSecondary)
            Text(value)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(palette.text)
        }
    }

    private func playerRow(_ person: Participant, isCurrent: Bool) -> some View {
        HStack(spacing: 14) {
            rowSwatch(person, isCurrent: isCurrent)
            VStack(alignment: .leading, spacing: 2) {
                Text(person.name)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                if isCurrent {
                    Text("Now")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(PlayerColor.color(person.colorIndex))
                }
            }
            Spacer(minLength: 8)
            Text("\(person.guessesUsed)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(palette.text)
                .accessibilityLabel(guessCountLabel(person.guessesUsed))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isCurrent ? PlayerColor.color(person.colorIndex).opacity(0.18) : Color.clear)
        )
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isCurrent ? .isSelected : [])
    }

    @ViewBuilder
    private func rowSwatch(_ person: Participant, isCurrent: Bool) -> some View {
        let swatch = PlayerSwatch(colorIndex: person.colorIndex, size: isCurrent ? 34 : 26)
        // The pip flies to the handoff screen. It stays in the row while someone is guessing.
        if isCurrent && model.phase == .playing {
            swatch.matchedGeometryEffect(id: "turnPip", in: namespace)
        } else {
            swatch
        }
    }
}
