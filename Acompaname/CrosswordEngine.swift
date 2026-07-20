import Foundation

struct CrosswordGameState: Equatable {
    let puzzle: CrosswordPuzzle
    var userLetters: [GridPosition: Character]
    var selectedCell: GridPosition?
    var activeEntryID: String?
    var hintsUsed: Int

    init(puzzle: CrosswordPuzzle) {
        self.puzzle = puzzle
        self.userLetters = [:]
        self.selectedCell = nil
        self.activeEntryID = nil
        self.hintsUsed = 0
    }

    var completedEntryIDs: Set<String> {
        Set(puzzle.entries.filter(isEntryComplete).map(\.id))
    }

    var solvedEntryCount: Int {
        completedEntryIDs.count
    }

    var totalEntries: Int {
        puzzle.entries.count
    }

    var isComplete: Bool {
        solvedEntryCount == totalEntries
    }

    var activeEntry: CrosswordEntrySpec? {
        guard let activeEntryID else { return nil }
        return puzzle.entries.first { $0.id == activeEntryID }
    }

    mutating func selectCell(_ position: GridPosition) {
        guard !puzzle.isBlock(position) else { return }

        let candidates = puzzle.entries(at: position)
        guard !candidates.isEmpty else { return }

        if let activeEntryID,
           candidates.contains(where: { $0.id == activeEntryID }) {
            selectedCell = position
            return
        }

        if candidates.count == 1 {
            activeEntryID = candidates[0].id
        } else if let current = activeEntryID,
                  let index = candidates.firstIndex(where: { $0.id == current }) {
            activeEntryID = candidates[(index + 1) % candidates.count].id
        } else {
            activeEntryID = candidates[0].id
        }

        selectedCell = position
    }

    mutating func enterLetter(_ letter: Character) {
        guard let entry = activeEntry, let selectedCell else { return }

        let cells = puzzle.cells(for: entry)
        guard cells.contains(selectedCell) else { return }

        userLetters[selectedCell] = Character(String(letter).uppercased())

        if let index = cells.firstIndex(of: selectedCell), index + 1 < cells.count {
            self.selectedCell = cells[index + 1]
        }
    }

    mutating func deleteLetter() {
        guard let entry = activeEntry, let selectedCell else { return }

        let cells = puzzle.cells(for: entry)
        guard let index = cells.firstIndex(of: selectedCell) else { return }

        if userLetters[selectedCell] != nil {
            userLetters.removeValue(forKey: selectedCell)
            return
        }

        if index > 0 {
            let previous = cells[index - 1]
            self.selectedCell = previous
            userLetters.removeValue(forKey: previous)
        }
    }

    mutating func selectEntry(_ entry: CrosswordEntrySpec) {
        activeEntryID = entry.id
        selectedCell = entry.start
    }

    mutating func applyHint() -> Bool {
        let pending = puzzle.entries.filter { !isEntryComplete($0) }
        guard let entry = pending.randomElement() else { return false }

        let cells = puzzle.cells(for: entry)
        let openCells = cells.filter { cell in
            userLetters[cell] != puzzle.solutionLetter(at: cell)
        }

        guard let cell = openCells.randomElement(),
              let letter = puzzle.solutionLetter(at: cell) else { return false }

        userLetters[cell] = letter
        activeEntryID = entry.id
        selectedCell = cell
        hintsUsed += 1
        return true
    }

    func displayLetter(at position: GridPosition) -> Character? {
        userLetters[position]
    }

    func isActiveCell(_ position: GridPosition) -> Bool {
        guard let entry = activeEntry else { return selectedCell == position }
        return puzzle.cells(for: entry).contains(position)
    }

    private func isEntryComplete(_ entry: CrosswordEntrySpec) -> Bool {
        puzzle.cells(for: entry).allSatisfy { position in
            userLetters[position] == puzzle.solutionLetter(at: position)
        }
    }
}
