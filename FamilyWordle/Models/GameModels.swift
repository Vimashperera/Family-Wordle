import Foundation

/// Shared rules for every mode. The grid is the classic Wordle shape.
enum GameRules {
    static let wordLength = 5
    static let maxGuesses = 6
    static let minPlayers = 2
    static let maxPlayers = 6
}

/// How the living room is sharing the puzzle.
enum GameMode: String, Equatable, CaseIterable, Identifiable {
    case solo
    case family
    case team

    var id: String { rawValue }

    var title: String {
        switch self {
        case .solo: "Solo"
        case .family: "Family mode"
        case .team: "Team mode"
        }
    }

    var setupDetail: String {
        switch self {
        case .solo:
            "Play today's shared word, or a practice word."
        case .family:
            "One grid for everyone. Each player makes a guess, then passes the remote."
        case .team:
            "Two sides share one grid and take turns."
        }
    }
}

/// Color of a tile after a guess is scored.
/// `.empty` is also the state of a letter that has been typed but not submitted.
enum TileFeedback: Equatable {
    case empty
    case correct
    case present
    case absent
}

/// One of the six rows on the board.
struct BoardRow: Identifiable, Equatable {
    let index: Int
    var letters: [Character]
    var feedback: [TileFeedback]
    var isSubmitted: Bool

    var id: Int { index }

    static func empty(index: Int) -> BoardRow {
        BoardRow(
            index: index,
            letters: [],
            feedback: Array(repeating: .empty, count: GameRules.wordLength),
            isSubmitted: false
        )
    }
}

/// A person or a team sitting on the couch. Color is an index into `PlayerColor`
/// so it can be stored without pulling SwiftUI into the model.
struct Participant: Identifiable, Equatable {
    let id: UUID
    var name: String
    var colorIndex: Int
    var guessesUsed: Int
    var solvedTheWord: Bool

    init(
        id: UUID = UUID(),
        name: String,
        colorIndex: Int,
        guessesUsed: Int = 0,
        solvedTheWord: Bool = false
    ) {
        self.id = id
        self.name = name
        self.colorIndex = colorIndex
        self.guessesUsed = guessesUsed
        self.solvedTheWord = solvedTheWord
    }
}

/// Where the round currently is. Family and team games open on `.handoff`
/// so the first player is announced before anyone can guess.
enum GamePhase: Equatable {
    case handoff
    case playing
    case results
}

/// On-screen keyboard keys. The view owns focus; the view model only sees letters.
enum KeyboardKey: Hashable, Identifiable {
    case letter(Character)
    case guess
    case delete

    var id: String {
        switch self {
        case .letter(let character): "L\(character)"
        case .guess: "guess"
        case .delete: "delete"
        }
    }

    static let rows: [[KeyboardKey]] = [
        Array("QWERTYUIOP").map { .letter($0) },
        Array("ASDFGHJKL").map { .letter($0) },
        [.guess] + Array("ZXCVBNM").map { .letter($0) } + [.delete]
    ]
}

/// "Alex's turn" / "Parents' turn". Names already ending in s get a trailing apostrophe only.
func possessive(_ name: String) -> String {
    let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard let last = trimmed.last else { return trimmed }
    return last.lowercased() == "s" ? "\(trimmed)'" : "\(trimmed)'s"
}

func guessCountLabel(_ count: Int) -> String {
    count == 1 ? "1 guess" : "\(count) guesses"
}
