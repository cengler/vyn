import Foundation

enum HangmanStatus: Equatable {
    case playing
    case won
    case lost
}

enum GuessOutcome: Equatable {
    case ignored
    case correct
    case wrong
}

struct HangmanGameState: Equatable {
    let round: HangmanRound
    var guessedLetters: Set<Character>
    var wrongCount: Int
    var hintsUsed: Int
    var wins: Int
    var losses: Int

    init(round: HangmanRound, wins: Int = 0, losses: Int = 0) {
        self.round = round
        self.guessedLetters = []
        self.wrongCount = 0
        self.hintsUsed = 0
        self.wins = wins
        self.losses = losses
    }

    var maxWrongGuesses: Int {
        HangmanCatalog.maxWrongGuesses
    }

    var remainingGuesses: Int {
        max(0, maxWrongGuesses - wrongCount)
    }

    var status: HangmanStatus {
        if isWordComplete {
            return .won
        }
        if wrongCount >= maxWrongGuesses {
            return .lost
        }
        return .playing
    }

    var isWordComplete: Bool {
        normalizedLetters(in: round.word).allSatisfy { guessedLetters.contains($0) }
    }

    var displayLetters: [Character?] {
        round.word.map { letter in
            let normalized = HangmanCatalog.normalizeLetter(letter)
            if guessedLetters.contains(normalized) {
                return normalized
            }
            return nil
        }
    }

    mutating func guess(_ letter: Character) -> GuessOutcome {
        guard status == .playing else { return .ignored }

        let normalized = HangmanCatalog.normalizeLetter(letter)
        guard normalized.isAlphaLetter else { return .ignored }
        guard !guessedLetters.contains(normalized) else { return .ignored }

        guessedLetters.insert(normalized)

        if normalizedLetters(in: round.word).contains(normalized) {
            return .correct
        }

        wrongCount += 1
        return .wrong
    }

    mutating func applyHint() -> Bool {
        guard status == .playing else { return false }

        let missing = normalizedLetters(in: round.word).filter { !guessedLetters.contains($0) }
        guard let letter = missing.randomElement() else { return false }

        guessedLetters.insert(letter)
        hintsUsed += 1
        return true
    }

    mutating func advanceAfterWin() -> HangmanGameState {
        HangmanGameState(
            round: HangmanCatalog.randomRound(excluding: round.id),
            wins: wins + 1,
            losses: losses
        )
    }

    mutating func advanceAfterLoss() -> HangmanGameState {
        HangmanGameState(
            round: HangmanCatalog.randomRound(excluding: round.id),
            wins: wins,
            losses: losses + 1
        )
    }

    private func normalizedLetters(in word: String) -> [Character] {
        word.compactMap { character in
            let normalized = HangmanCatalog.normalizeLetter(character)
            return normalized.isAlphaLetter ? normalized : nil
        }
    }
}

private extension Character {
    var isAlphaLetter: Bool {
        String(self).rangeOfCharacter(from: CharacterSet.letters) != nil
    }
}
