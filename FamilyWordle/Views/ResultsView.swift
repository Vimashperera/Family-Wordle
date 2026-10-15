import SwiftUI

struct ResultsView: View {
    @ObservedObject var model: GameViewModel
    var focus: FocusState<GameFocus>.Binding
    var onPractice: () -> Void
    var onMenu: () -> Void

    @Environment(\.palette) private var palette
    @EnvironmentObject private var store: PersistenceStore

    private var solved: Bool { model.winner != nil }

    var body: some View {
        ZStack {
            palette.background.ignoresSafeArea()
            if solved, let winner = model.winner {
                CelebrationBurst(color: PlayerColor.color(winner.colorIndex))
                    .allowsHitTesting(false)
            }

            HStack(alignment: .center, spacing: 56) {
                outcome
                    .frame(maxWidth: .infinity, alignment: .leading)
                sidePanel
                    .frame(width: 520)
            }
            .padding(.horizontal, 64)
            .padding(.vertical, 36)
        }
    }

    private var outcome: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text(headline)
                .font(.system(size: 68, weight: .bold, design: .rounded))
                .foregroundStyle(headlineColor)
                .lineLimit(2)
                .minimumScaleFactor(0.6)

            Text(subhead)
                .font(.system(size: 30, weight: .medium, design: .rounded))
                .foregroundStyle(palette.textSecondary)

            HStack(spacing: 10) {
                ForEach(0..<GameRules.wordLength, id: \.self) { index in
                    TileView(
                        letter: Array(model.answer.uppercased())[index],
                        feedback: .correct,
                        isSubmitted: true,
                        flipDelay: Double(index) * 0.08,
                        accent: palette.gold,
                        isActive: false,
                        tileSize: 96,
                        startsRevealed: solved
                    )
                }
            }
            .padding(.vertical, 6)

            if model.mode != .solo {
                VStack(spacing: 10) {
                    ForEach(orderedParticipants) { person in
                        HStack(spacing: 14) {
                            PlayerSwatch(colorIndex: person.colorIndex, size: 26)
                            Text(person.name)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(palette.text)
                            Spacer()
                            if person.solvedTheWord {
                                Text("Solved it")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundStyle(PlayerColor.color(person.colorIndex))
                            } else {
                                Text(guessCountLabel(person.guessesUsed))
                                    .font(.system(size: 24, weight: .medium, design: .rounded))
                                    .foregroundStyle(palette.textSecondary)
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }

            HStack(spacing: 18) {
                Button(action: onPractice) {
                    Text("New practice round")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.card)
                .focused(focus, equals: .practiceAgain)

                Button(action: onMenu) {
                    Text("Main menu")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.card)
                .focused(focus, equals: .mainMenu)
            }
            .padding(.top, 10)
        }
    }

    private var sidePanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            if model.mode == .solo {
                Text("Your streak")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.text)
                Text("\(store.soloStats.currentStreak)")
                    .font(.system(size: 84, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.gold)
                Text(model.usesDailyWord
                     ? "Daily games update this once a day."
                     : "Practice rounds stay off your streak.")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 24) {
                    miniStat("Played", "\(store.soloStats.played)")
                    miniStat("Wins", "\(store.soloStats.wins)")
                    miniStat("Best", "\(store.soloStats.maxStreak)")
                }
            } else {
                Text("Household")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.text)
                Text("Points stick around after the TV goes off.")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
                ForEach(Array(store.rankedRecords.prefix(6).enumerated()), id: \.element.name) { index, entry in
                    HStack(spacing: 14) {
                        Text("\(index + 1)")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(palette.gold)
                            .frame(width: 28, alignment: .leading)
                        Text(entry.name)
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                            .lineLimit(1)
                            .foregroundStyle(palette.text)
                        Spacer()
                        Text("\(entry.record.points)")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(palette.text)
                    }
                    .padding(.vertical, 4)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(32)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(palette.surface)
        )
    }

    private var orderedParticipants: [Participant] {
        let winners = model.participants.filter(\.solvedTheWord)
        let others = model.participants.filter { !$0.solvedTheWord }
        return winners + others
    }

    private var headline: String {
        if let winner = model.winner {
            return "\(winner.name) got it"
        }
        return "Not this time"
    }

    private var headlineColor: Color {
        if let winner = model.winner, model.mode != .solo {
            return PlayerColor.color(winner.colorIndex)
        }
        return palette.text
    }

    private var subhead: String {
        if let guess = model.solvedOnGuess {
            if model.mode == .solo {
                return "Solved on guess \(guess)."
            }
            let label = model.pointsAwarded == 1 ? "1 point" : "\(model.pointsAwarded) points"
            return "Solved on guess \(guess). \(label) on the household board."
        }
        return "The word stays on the table."
    }

    private func miniStat(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundStyle(palette.textSecondary)
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(palette.text)
        }
    }
}

/// A short burst behind a winning name. Reduced motion skips it.
private struct CelebrationBurst: View {
    let color: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var burst = false

    var body: some View {
        ZStack {
            ForEach(0..<28, id: \.self) { index in
                Circle()
                    .fill(index.isMultiple(of: 3) ? color : Color(hex: 0xF0C56E))
                    .frame(width: CGFloat(10 + (index % 4) * 6), height: CGFloat(10 + (index % 4) * 6))
                    .offset(burst ? offset(for: index) : .zero)
                    .opacity(burst ? 0 : 0.95)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.leading, 180)
        .padding(.top, 80)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeOut(duration: 1.35)) {
                burst = true
            }
        }
        .accessibilityHidden(true)
    }

    private func offset(for index: Int) -> CGSize {
        let angle = Double(index) / 28 * Double.pi * 2
        let distance = CGFloat(180 + (index % 5) * 48)
        return CGSize(width: cos(angle) * distance, height: sin(angle) * distance * 0.72)
    }
}
