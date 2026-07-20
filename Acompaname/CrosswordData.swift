import Foundation

enum CrosswordDirection: String, Codable {
    case across
    case down
}

struct CrosswordEntrySpec: Identifiable, Equatable {
    let id: String
    let number: Int
    let direction: CrosswordDirection
    let clue: String
    let answer: String
    let startRow: Int
    let startCol: Int

    var start: GridPosition {
        GridPosition(row: startRow, col: startCol)
    }
}

struct CrosswordPuzzleSpec: Identifiable, Equatable {
    let id: String
    let rows: Int
    let cols: Int
    let entries: [CrosswordEntrySpec]
}

struct CrosswordPuzzle: Equatable {
    let spec: CrosswordPuzzleSpec
    let solution: [[Character?]]
    let blocks: Set<GridPosition>
    let cellNumbers: [GridPosition: Int]
    let entries: [CrosswordEntrySpec]

    func cells(for entry: CrosswordEntrySpec) -> [GridPosition] {
        let delta = entry.direction == .across ? (0, 1) : (1, 0)
        return entry.answer.enumerated().map { index, _ in
            GridPosition(row: entry.startRow + delta.0 * index, col: entry.startCol + delta.1 * index)
        }
    }

    func entry(containing position: GridPosition) -> CrosswordEntrySpec? {
        entries.first { cells(for: $0).contains(position) }
    }

    func entries(at position: GridPosition) -> [CrosswordEntrySpec] {
        entries.filter { cells(for: $0).contains(position) }
    }

    func solutionLetter(at position: GridPosition) -> Character? {
        guard position.row >= 0, position.row < spec.rows,
              position.col >= 0, position.col < spec.cols else { return nil }
        return solution[position.row][position.col]
    }

    func isBlock(_ position: GridPosition) -> Bool {
        blocks.contains(position)
    }
}

enum CrosswordCatalog {
    static let puzzles: [CrosswordPuzzleSpec] = [
        CrosswordPuzzleSpec(
            id: "minecraft-tools",
            rows: 9,
            cols: 9,
            entries: [
                CrosswordEntrySpec(
                    id: "c1-e1",
                    number: 1,
                    direction: .across,
                    clue: "Mob verde que explota",
                    answer: "CREEPER",
                    startRow: 1,
                    startCol: 1
                ),
                CrosswordEntrySpec(
                    id: "c1-e2",
                    number: 2,
                    direction: .down,
                    clue: "Arma para combatir",
                    answer: "ESPADA",
                    startRow: 1,
                    startCol: 3
                ),
                CrosswordEntrySpec(
                    id: "c1-e3",
                    number: 3,
                    direction: .down,
                    clue: "Herramienta para minar",
                    answer: "PICO",
                    startRow: 1,
                    startCol: 5
                ),
                CrosswordEntrySpec(
                    id: "c1-e4",
                    number: 4,
                    direction: .down,
                    clue: "Mineral negro combustible",
                    answer: "CARBON",
                    startRow: 1,
                    startCol: 1
                ),
                CrosswordEntrySpec(
                    id: "c1-e5",
                    number: 5,
                    direction: .down,
                    clue: "Líquido ardiente rojo",
                    answer: "LAVA",
                    startRow: 2,
                    startCol: 7
                ),
            ]
        ),
        CrosswordPuzzleSpec(
            id: "minecraft-blocks",
            rows: 8,
            cols: 8,
            entries: [
                CrosswordEntrySpec(
                    id: "c2-e1",
                    number: 1,
                    direction: .across,
                    clue: "Dispara flechas",
                    answer: "ARCO",
                    startRow: 1,
                    startCol: 1
                ),
                CrosswordEntrySpec(
                    id: "c2-e2",
                    number: 2,
                    direction: .down,
                    clue: "Bloque amarillo del desierto",
                    answer: "ARENA",
                    startRow: 1,
                    startCol: 1
                ),
                CrosswordEntrySpec(
                    id: "c2-e3",
                    number: 3,
                    direction: .across,
                    clue: "Polvo rojo eléctrico",
                    answer: "REDSTONE",
                    startRow: 3,
                    startCol: 0
                ),
            ]
        ),
    ]

    static func randomPuzzle() -> CrosswordPuzzle {
        let spec = puzzles.randomElement() ?? puzzles[0]
        return buildPuzzle(from: spec)
    }

    static func buildPuzzle(from spec: CrosswordPuzzleSpec) -> CrosswordPuzzle {
        var solution = Array(repeating: Array<Character?>(repeating: nil, count: spec.cols), count: spec.rows)
        var blocks = Set<GridPosition>()

        for row in 0..<spec.rows {
            for col in 0..<spec.cols {
                blocks.insert(GridPosition(row: row, col: col))
            }
        }

        for entry in spec.entries {
            let delta = entry.direction == .across ? (0, 1) : (1, 0)
            for (index, letter) in entry.answer.enumerated() {
                let position = GridPosition(
                    row: entry.startRow + delta.0 * index,
                    col: entry.startCol + delta.1 * index
                )
                blocks.remove(position)

                if let existing = solution[position.row][position.col], existing != letter {
                    assertionFailure("Crossword conflict at \(position)")
                }
                solution[position.row][position.col] = letter
            }
        }

        var cellNumbers: [GridPosition: Int] = [:]
        for entry in spec.entries {
            let start = entry.start
            if let existing = cellNumbers[start] {
                cellNumbers[start] = min(existing, entry.number)
            } else {
                cellNumbers[start] = entry.number
            }
        }

        return CrosswordPuzzle(
            spec: spec,
            solution: solution,
            blocks: blocks,
            cellNumbers: cellNumbers,
            entries: spec.entries.sorted {
                if $0.number == $1.number {
                    return $0.direction.rawValue < $1.direction.rawValue
                }
                return $0.number < $1.number
            }
        )
    }
}
