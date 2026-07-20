import Foundation

struct GridPosition: Hashable {
    let row: Int
    let col: Int
}

struct PlacedWord: Identifiable {
    let id: String
    let word: String
    let cells: [GridPosition]
}

struct WordSearchPuzzle {
    let grid: [[Character]]
    let words: [String]
    let placements: [PlacedWord]
    let rows: Int
    let cols: Int
}

enum WordTheme: String, CaseIterable, Identifiable {
    case random
    case minecraft

    var id: String { rawValue }

    var title: String {
        switch self {
        case .random: String(localized: "mode.random.title")
        case .minecraft: String(localized: "mode.minecraft.title")
        }
    }

    var subtitle: String {
        switch self {
        case .random: String(localized: "mode.random.subtitle")
        case .minecraft: String(localized: "mode.minecraft.subtitle")
        }
    }
}

enum WordBank {
    static let spanishWords: [String] = [
        "SOL", "LUNA", "CASA", "GATO", "PERRO", "AGUA", "FLOR", "AMOR", "MESA", "SILLA",
        "PUERTA", "CAMPO", "PLAYA", "MONTE", "BOSQUE", "RIO", "MAR", "PEZ", "PAJARO", "HOJA",
        "FRUTA", "MANZANA", "PERA", "UVA", "CAFE", "AZUCAR", "SAL", "FUEGO", "AIRE", "TIERRA",
        "CIELO", "NUBE", "LLUVIA", "VIENTO", "FRIO", "CALOR", "DIA", "NOCHE", "ESTRELLA", "LUZ",
        "ROJO", "AZUL", "VERDE", "BLANCO", "NEGRO", "ROSA", "GRIS", "MANO", "PIE", "OJO",
        "BOCA", "CARA", "BRAZO", "PIERNA", "COMIDA", "CENA", "PAN", "QUESO", "HUEVO", "CARNE",
        "ARROZ", "SOPA", "JUGO", "DULCE", "LIBRO", "LAPIZ", "PAPEL", "ESCUELA", "CLASE", "JUEGO",
        "PELOTA", "CORRER", "SALTAR", "CAMINAR", "CANTAR", "BAILAR", "DORMIR", "SONAR", "REIR", "HABLAR",
        "MIRAR", "COMER", "BEBER", "VIVIR", "DEDO", "RELOJ", "CAMA", "TOALLA", "JABON", "ESPEJO",
        "VENTANA", "TECHO", "PISO", "JARDIN", "PLANTA", "SEMILLA", "HIERBA", "RAMA", "HORMIGA", "ABEJA",
        "PATO", "VACA", "OVEJA", "CERDO", "RATON", "LEON", "OSO", "MONO", "CIUDAD", "CALLE"
    ]

    static let minecraft: [String] = [
        "STEVE", "ALEX", "CREEPER", "ZOMBIE", "ESQUELETO", "ARANA", "ENDER", "NETHER", "PICO", "HACHA",
        "ESPADA", "ARCO", "FLECHA", "BLOQUE", "TIERRA", "PIEDRA", "ARENA", "LAVA", "HIELO", "NIEVE",
        "MADERA", "TRONCO", "SEMILLA", "TRIGO", "CARNE", "POLLO", "VACA", "CERDO", "OVEJA", "LOBO",
        "SALMON", "CALAMAR", "GOLEM", "ALDEA", "LIBRO", "REDSTONE", "OBSIDIAN", "DIAMANTE", "HIERRO", "CARBON",
        "COBRE", "EMERALD", "LAPIS", "CRISTAL", "ANTORCHA", "COFRE", "FORJA", "BRUJULA", "CUEVA", "PORTAL"
    ]

    static func words(for theme: WordTheme) -> [String] {
        switch theme {
        case .random: spanishWords
        case .minecraft: minecraft
        }
    }
}

enum WordSearchGenerator {
    static let fixedColumns = 8
    static let minRows = 8
    static let maxRows = 18

    private static let directions = [
        (0, 1), (1, 0), (1, 1), (1, -1),
        (0, -1), (-1, 0), (-1, -1), (-1, 1)
    ]

    static func newGame(
        rows: Int = minRows,
        columns: Int = fixedColumns,
        wordCount: Int = 6,
        theme: WordTheme = .random
    ) -> WordSearchPuzzle {
        let rowCount = min(max(rows, minRows), maxRows)
        let colCount = fixedColumns
        let maxWordLength = min(colCount, rowCount)
        let bank = WordBank.words(for: theme)
        let candidates = bank.filter { $0.count <= maxWordLength }
        let selected = Array(candidates.shuffled().prefix(wordCount))

        for _ in 0..<500 {
            if let puzzle = tryGenerate(words: selected, rows: rowCount, cols: colCount) {
                return puzzle
            }
            let others = Array(candidates.shuffled().prefix(wordCount))
            if let puzzle = tryGenerate(words: others, rows: rowCount, cols: colCount) {
                return puzzle
            }
        }
        return fallback(words: selected, rows: rowCount, cols: colCount)
    }

    private static func tryGenerate(words: [String], rows: Int, cols: Int) -> WordSearchPuzzle? {
        let sorted = words.sorted { $0.count > $1.count }
        var grid = Array(repeating: Array(repeating: Character(" "), count: cols), count: rows)
        var placements: [PlacedWord] = []

        for word in sorted {
            guard let placement = place(word: word, in: &grid, rows: rows, cols: cols) else {
                return nil
            }
            placements.append(placement)
        }

        fillEmptyCells(in: &grid, rows: rows, cols: cols)
        return WordSearchPuzzle(
            grid: grid,
            words: words.sorted(),
            placements: placements,
            rows: rows,
            cols: cols
        )
    }

    private static func place(word: String, in grid: inout [[Character]], rows: Int, cols: Int) -> PlacedWord? {
        let letters = Array(word)
        let shuffledDirections = directions.shuffled()

        for _ in 0..<80 {
            let direction = shuffledDirections.randomElement()!
            let startRow = Int.random(in: 0..<rows)
            let startCol = Int.random(in: 0..<cols)

            var cells: [GridPosition] = []
            var isValid = true

            for (index, letter) in letters.enumerated() {
                let row = startRow + direction.0 * index
                let col = startCol + direction.1 * index
                guard row >= 0, row < rows, col >= 0, col < cols else {
                    isValid = false
                    break
                }
                let current = grid[row][col]
                if current != " " && current != letter {
                    isValid = false
                    break
                }
                cells.append(GridPosition(row: row, col: col))
            }

            guard isValid else { continue }

            for (index, letter) in letters.enumerated() {
                let cell = cells[index]
                grid[cell.row][cell.col] = letter
            }

            return PlacedWord(id: word, word: word, cells: cells)
        }

        return nil
    }

    private static func fillEmptyCells(in grid: inout [[Character]], rows: Int, cols: Int) {
        let letters = Array("AEIOULRSTNCPMDG")
        for row in 0..<rows {
            for col in 0..<cols where grid[row][col] == " " {
                grid[row][col] = letters.randomElement()!
            }
        }
    }

    private static func fallback(words: [String], rows: Int, cols: Int) -> WordSearchPuzzle {
        var grid = Array(repeating: Array(repeating: Character("A"), count: cols), count: rows)
        var placements: [PlacedWord] = []

        for (index, word) in words.enumerated() {
            let row = min(index, rows - 1)
            var cells: [GridPosition] = []
            for (offset, letter) in word.enumerated() where offset < cols {
                grid[row][offset] = letter
                cells.append(GridPosition(row: row, col: offset))
            }
            placements.append(PlacedWord(id: word, word: word, cells: cells))
        }

        fillEmptyCells(in: &grid, rows: rows, cols: cols)
        return WordSearchPuzzle(
            grid: grid,
            words: words.sorted(),
            placements: placements,
            rows: rows,
            cols: cols
        )
    }

    static func word(in selection: [GridPosition], puzzle: WordSearchPuzzle) -> String? {
        guard selection.count >= 2 else { return nil }

        let chars = selection.map { puzzle.grid[$0.row][$0.col] }
        let forward = String(chars)
        let backward = String(chars.reversed())

        for placement in puzzle.placements {
            if forward == placement.word || backward == placement.word {
                return placement.word
            }
        }
        return nil
    }

    static func cells(for word: String, in puzzle: WordSearchPuzzle) -> Set<GridPosition> {
        guard let placement = puzzle.placements.first(where: { $0.word == word }) else {
            return []
        }
        return Set(placement.cells)
    }
}

struct GridLayoutMetrics: Equatable {
    let columns: Int
    let rows: Int
    let cellSize: CGFloat
    let gridWidth: CGFloat
    let gridHeight: CGFloat

    static let `default` = GridLayoutMetrics(
        columns: 8,
        rows: 8,
        cellSize: 32,
        gridWidth: 263,
        gridHeight: 263
    )
}

enum GridLayoutCalculator {
    static let spacing: CGFloat = 1

    static func calculate(width: CGFloat, availableHeight: CGFloat) -> GridLayoutMetrics {
        let columns = WordSearchGenerator.fixedColumns
        let usableWidth = max(width, 100)
        let usableHeight = max(availableHeight, 100)

        let cellSize = (usableWidth - spacing * CGFloat(columns - 1)) / CGFloat(columns)
        var rows = Int(floor((usableHeight + spacing) / (cellSize + spacing)))
        rows = min(max(rows, WordSearchGenerator.minRows), WordSearchGenerator.maxRows)

        let gridWidth = cellSize * CGFloat(columns) + spacing * CGFloat(columns - 1)
        let gridHeight = cellSize * CGFloat(rows) + spacing * CGFloat(rows - 1)

        return GridLayoutMetrics(
            columns: columns,
            rows: rows,
            cellSize: cellSize,
            gridWidth: gridWidth,
            gridHeight: gridHeight
        )
    }
}
