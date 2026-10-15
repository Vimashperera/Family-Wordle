import Foundation

/// Scores a guess the way Wordle does, including duplicate letters.
///
/// Two passes:
/// 1. Mark exact matches and consume those letters in the answer.
/// 2. Mark remaining letters as present only if an unused copy is still in the answer.
///
/// Example: guess ALLOT, answer LLAMA.
/// Exact match at index 1 (L). The first A is present, the second L is present,
/// O and T are absent. The second A in the answer is not a free match for a second A
/// in the guess, because this guess only has one A.
enum WordScorer {
    static func score(guess: String, answer: String) -> [TileFeedback] {
        let guessChars = Array(guess.lowercased())
        var answerChars = Array(answer.lowercased())
        let length = GameRules.wordLength
        guard guessChars.count == length, answerChars.count == length else {
            return Array(repeating: .absent, count: length)
        }

        var result = Array(repeating: TileFeedback.absent, count: length)

        for index in 0..<length where guessChars[index] == answerChars[index] {
            result[index] = .correct
            answerChars[index] = "*"
        }

        for index in 0..<length where result[index] != .correct {
            if let match = answerChars.firstIndex(of: guessChars[index]) {
                result[index] = .present
                answerChars[match] = "*"
            }
        }

        return result
    }
}
