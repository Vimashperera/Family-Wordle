import SwiftUI

/// One shared puzzle.
///
/// Solo stays on `.playing` until the word is solved or the sixth guess misses.
/// Family and team open on `.handoff`, then alternate:
///
///     handoff → playing → (flip) → handoff → … → results
///
/// Everyone shares the six rows. The player who turns the row green wins the round
/// and scores `7 - guessNumber` household points (6 points on the first guess, 1 on the last).
@MainActor
final class GameViewModel: ObservableObject {
    let mode: GameMode

    @Published private(set) var participants: [Participant]
    @Published private(set) var rows: [BoardRow]
    @Published private(set) var currentGuess = ""
    @Published private(set) var currentRow = 0
    @Published private(set) var currentIndex = 0
    @Published private(set) var phase: GamePhase
    @Published private(set) var banner: String?
    @Published private(set) var shakeToken = 0
    @Published private(set) var celebrateRow: Int?
    @Published private(set) var keyStates: [Character: TileFeedback] = [:]
    @Published private(set) var isRevealing = false
    @Published private(set) var answer: String
    @Published private(set) var usesDailyWord: Bool
    @Published private(set) var pointsAwarded = 0
    @Published private(set) var solvedOnGuess: Int?
    @Published private(set) var roundID = UUID()

    private let store: PersistenceStore
    private var revealTask: Task<Void, Never>?
    private var isAbandoned = false
    private var didRecord = false

    init(mode: GameMode, participants: [Participant], usesDailyWord: Bool, store: PersistenceStore) {
        self.mode = mode
        self.participants = participants
        self.usesDailyWord = usesDailyWord
        self.store = store
        answer = usesDailyWord ? WordBank.dailyAnswer() : WordBank.practiceAnswer()
        rows = (0..<GameRules.maxGuesses).map(BoardRow.empty)
        phase = mode == .solo ? .playing : .handoff
    }

    var current: Participant {
        participants[currentIndex]
    }

    var guessesRemaining: Int {
        GameRules.maxGuesses - rows.filter(\.isSubmitted).count
    }

    var turnTitle: String {
        switch mode {
        case .solo:
            usesDailyWord ? "Today's word" : "Practice"
        case .family, .team:
            "\(possessive(current.name)) turn"
        }
    }

    var winner: Participant? {
        participants.first { $0.solvedTheWord }
    }

    func append(_ character: Character) {
        guard phase == .playing, !isRevealing else { return }
        guard currentGuess.count < GameRules.wordLength else { return }
        let upper = Character(String(character).uppercased())
        guard upper.isLetter, upper.unicodeScalars.allSatisfy({ $0.isASCII }) else { return }
        currentGuess.append(upper)
        banner = nil
    }

    func deleteLetter() {
        guard phase == .playing, !isRevealing else { return }
        guard !currentGuess.isEmpty else { return }
        currentGuess.removeLast()
        banner = nil
    }

    func submit() {
        guard phase == .playing, !isRevealing else { return }

        guard currentGuess.count == GameRules.wordLength else {
            reject(with: "Enter 5 letters")
            return
        }

        let guess = currentGuess.lowercased()
        guard WordBank.contains(guess) else {
            reject(with: "Not in the word list")
            return
        }

        let feedback = WordScorer.score(guess: guess, answer: answer)
        let rowIndex = currentRow
        var row = rows[rowIndex]
        row.letters = Array(currentGuess)
        row.feedback = feedback
        row.isSubmitted = true
        rows[rowIndex] = row
        participants[currentIndex].guessesUsed += 1
        mergeKeyboard(feedback, letters: Array(guess.uppercased()))
        currentGuess = ""
        banner = nil
        isRevealing = true
        SoundPlayer.play(.tap, enabled: store.settings.soundEnabled)

        let solved = feedback.allSatisfy { $0 == .correct }
        let round = roundID

        revealTask?.cancel()
        revealTask = Task { @MainActor in
            do {
                try await Task.sleep(for: .milliseconds(980))
            } catch {
                return
            }
            guard !Task.isCancelled, !isAbandoned, roundID == round else { return }

            isRevealing = false
            if solved {
                participants[currentIndex].solvedTheWord = true
                solvedOnGuess = rowIndex + 1
                pointsAwarded = 7 - (rowIndex + 1)
                celebrateRow = rowIndex
                SoundPlayer.play(.success, enabled: store.settings.soundEnabled)
                do {
                    try await Task.sleep(for: .milliseconds(460))
                } catch {
                    return
                }
                guard !Task.isCancelled, !isAbandoned, roundID == round else { return }
                finishRound(solved: true, guessesUsed: rowIndex + 1)
            } else if rowIndex == GameRules.maxGuesses - 1 {
                SoundPlayer.play(.miss, enabled: store.settings.soundEnabled)
                finishRound(solved: false, guessesUsed: GameRules.maxGuesses)
            } else {
                currentRow += 1
                advanceTurn()
            }
        }
    }

    func confirmHandoff() {
        guard phase == .handoff else { return }
        withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
            phase = .playing
        }
        banner = nil
    }

    /// Leaves the round without writing a result. Cancels an in-flight tile flip.
    func abandon() {
        isAbandoned = true
        revealTask?.cancel()
    }

    func startRematch() {
        revealTask?.cancel()
        isAbandoned = false
        didRecord = false
        answer = WordBank.practiceAnswer(excluding: answer)
        usesDailyWord = false
        rows = (0..<GameRules.maxGuesses).map(BoardRow.empty)
        currentGuess = ""
        currentRow = 0
        currentIndex = 0
        keyStates = [:]
        banner = nil
        celebrateRow = nil
        isRevealing = false
        pointsAwarded = 0
        solvedOnGuess = nil
        roundID = UUID()
        for index in participants.indices {
            participants[index].guessesUsed = 0
            participants[index].solvedTheWord = false
        }
        withAnimation(.easeInOut(duration: 0.3)) {
            phase = mode == .solo ? .playing : .handoff
        }
    }

    static func previewFamily() -> GameViewModel {
        GameViewModel(
            mode: .family,
            participants: [
                Participant(name: "Maya", colorIndex: 0),
                Participant(name: "Dad", colorIndex: 1),
                Participant(name: "Sam", colorIndex: 2)
            ],
            usesDailyWord: true,
            store: .preview()
        )
    }

    private func advanceTurn() {
        guard mode != .solo else { return }
        currentIndex = (currentIndex + 1) % participants.count
        withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
            phase = .handoff
        }
    }

    private func finishRound(solved: Bool, guessesUsed: Int) {
        guard !didRecord else { return }
        didRecord = true
        store.recordRound(
            mode: mode,
            participants: participants,
            solved: solved,
            points: pointsAwarded,
            guessesUsed: guessesUsed,
            daily: usesDailyWord
        )
        withAnimation(.spring(response: 0.5, dampingFraction: 0.84)) {
            phase = .results
        }
    }

    private func reject(with message: String) {
        banner = message
        shakeToken += 1
        SoundPlayer.play(.reject, enabled: store.settings.soundEnabled)
    }

    /// Correct beats present, present beats absent. A later gray never downgrades a key.
    private func mergeKeyboard(_ feedback: [TileFeedback], letters: [Character]) {
        for (letter, state) in zip(letters, feedback) {
            keyStates[letter] = merged(keyStates[letter], state)
        }
    }

    private func merged(_ current: TileFeedback?, _ new: TileFeedback) -> TileFeedback {
        if current == .correct || new == .correct { return .correct }
        if current == .present || new == .present { return .present }
        return .absent
    }
}
