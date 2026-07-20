import Foundation

enum MergeTier: Int, CaseIterable {
    case wood = 1
    case stone = 2
    case iron = 3
    case diamond = 4
    case netherite = 5

    static let winTier: MergeTier = .netherite

    var iconID: String {
        switch self {
        case .wood: "oak_planks"
        case .stone: "cobblestone"
        case .iron: "iron_ingot"
        case .diamond: "diamond"
        case .netherite: "netherite_chestplate"
        }
    }

    var displayName: String { L10n.item(iconID) }
}

struct Merge2048Tile: Identifiable, Equatable {
    let id: UUID
    var value: Int
}

struct Merge2048MoveOutcome: Equatable {
    let moved: Bool
    let mergedTileIDs: Set<UUID>
    let spawnedTileID: UUID?
}

struct Merge2048State: Equatable {
    var cells: [[UUID?]]
    var tiles: [UUID: Merge2048Tile]
    var score: Int
    var hasWon: Bool
    var isGameOver: Bool

    static let size = 4

    static func newGame() -> Merge2048State {
        var state = Merge2048State(
            cells: Array(repeating: Array(repeating: nil, count: size), count: size),
            tiles: [:],
            score: 0,
            hasWon: false,
            isGameOver: false
        )
        _ = state.spawnTile()
        _ = state.spawnTile()
        return state
    }

    mutating func reset() {
        self = Self.newGame()
    }

    mutating func move(_ direction: Merge2048Direction) -> Merge2048MoveOutcome {
        guard !isGameOver else {
            return Merge2048MoveOutcome(moved: false, mergedTileIDs: [], spawnedTileID: nil)
        }

        var nextCells = emptyCellsGrid()
        var nextTiles = tiles
        var mergedTileIDs: Set<UUID> = []
        var gained = 0

        switch direction {
        case .left:
            for row in 0..<Self.size {
                let result = processLine(line(inRow: row), tiles: &nextTiles)
                for (col, tile) in result.line.enumerated() {
                    nextCells[row][col] = tile.id
                }
                mergedTileIDs.formUnion(result.mergedTileIDs)
                gained += result.score
            }
        case .right:
            for row in 0..<Self.size {
                let result = processLine(line(inRow: row).reversed(), tiles: &nextTiles)
                for (offset, tile) in result.line.enumerated() {
                    nextCells[row][Self.size - 1 - offset] = tile.id
                }
                mergedTileIDs.formUnion(result.mergedTileIDs)
                gained += result.score
            }
        case .up:
            for col in 0..<Self.size {
                let result = processLine(line(inColumn: col), tiles: &nextTiles)
                for (row, tile) in result.line.enumerated() {
                    nextCells[row][col] = tile.id
                }
                mergedTileIDs.formUnion(result.mergedTileIDs)
                gained += result.score
            }
        case .down:
            for col in 0..<Self.size {
                let result = processLine(line(inColumn: col).reversed(), tiles: &nextTiles)
                for (offset, tile) in result.line.enumerated() {
                    nextCells[Self.size - 1 - offset][col] = tile.id
                }
                mergedTileIDs.formUnion(result.mergedTileIDs)
                gained += result.score
            }
        }

        let moved = nextCells != cells
        guard moved else {
            return Merge2048MoveOutcome(moved: false, mergedTileIDs: [], spawnedTileID: nil)
        }

        cells = nextCells
        tiles = nextTiles
        score += gained
        let spawnedTileID = spawnTile()
        updateStatus()

        return Merge2048MoveOutcome(
            moved: true,
            mergedTileIDs: mergedTileIDs,
            spawnedTileID: spawnedTileID
        )
    }

    func position(of tileID: UUID) -> GridPosition? {
        for row in 0..<Self.size {
            for col in 0..<Self.size where cells[row][col] == tileID {
                return GridPosition(row: row, col: col)
            }
        }
        return nil
    }

    var activeTiles: [Merge2048Tile] {
        Array(tiles.values)
    }

    @discardableResult
    private mutating func spawnTile() -> UUID? {
        let empties = emptyCellPositions()
        guard let cell = empties.randomElement() else { return nil }

        let tile = Merge2048Tile(id: UUID(), value: MergeTier.wood.rawValue)
        tiles[tile.id] = tile
        cells[cell.row][cell.col] = tile.id
        return tile.id
    }

    private mutating func updateStatus() {
        if !hasWon, tiles.values.contains(where: { $0.value == MergeTier.winTier.rawValue }) {
            hasWon = true
        }

        if emptyCellPositions().isEmpty, !canMergeAnywhere() {
            isGameOver = true
        }
    }

    private func emptyCellsGrid() -> [[UUID?]] {
        Array(repeating: Array(repeating: UUID?.none, count: Self.size), count: Self.size)
    }

    private func emptyCellPositions() -> [GridPosition] {
        var positions: [GridPosition] = []
        for row in 0..<Self.size {
            for col in 0..<Self.size where cells[row][col] == nil {
                positions.append(GridPosition(row: row, col: col))
            }
        }
        return positions
    }

    private func line(inRow row: Int) -> [Merge2048Tile] {
        (0..<Self.size).compactMap { col in
            guard let id = cells[row][col], let tile = tiles[id] else { return nil }
            return tile
        }
    }

    private func line(inColumn col: Int) -> [Merge2048Tile] {
        (0..<Self.size).compactMap { row in
            guard let id = cells[row][col], let tile = tiles[id] else { return nil }
            return tile
        }
    }

    private func canMergeAnywhere() -> Bool {
        for row in 0..<Self.size {
            for col in 0..<Self.size {
                guard let id = cells[row][col], let value = tiles[id]?.value else { continue }

                if value < MergeTier.netherite.rawValue {
                    if col + 1 < Self.size,
                       let rightID = cells[row][col + 1],
                       tiles[rightID]?.value == value {
                        return true
                    }
                    if row + 1 < Self.size,
                       let downID = cells[row + 1][col],
                       tiles[downID]?.value == value {
                        return true
                    }
                }
            }
        }
        return false
    }

    private struct LineResult {
        let line: [Merge2048Tile]
        let mergedTileIDs: Set<UUID>
        let score: Int
    }

    private func processLine(_ input: [Merge2048Tile], tiles: inout [UUID: Merge2048Tile]) -> LineResult {
        var working = input
        var mergedTileIDs: Set<UUID> = []
        var gained = 0
        var index = 0

        while index < working.count - 1 {
            if working[index].value == working[index + 1].value,
               working[index].value < MergeTier.netherite.rawValue {
                let removedID = working[index + 1].id
                working[index].value += 1
                tiles[working[index].id] = working[index]
                tiles.removeValue(forKey: removedID)
                mergedTileIDs.insert(working[index].id)
                working.remove(at: index + 1)
                gained += working[index].value * 10
            }
            index += 1
        }

        for tile in working where tiles[tile.id] != tile {
            tiles[tile.id] = tile
        }

        return LineResult(line: working, mergedTileIDs: mergedTileIDs, score: gained)
    }
}

enum Merge2048Direction {
    case up, down, left, right
}
