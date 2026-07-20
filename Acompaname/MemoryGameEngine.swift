import Foundation

struct MemoryCard: Identifiable, Equatable {
    let id: UUID
    let itemID: String
    var isFaceUp: Bool
    var isMatched: Bool
}

enum MemoryGameEngine {
    static let pairCount = 8
    static let columns = 4

    static func newGame() -> [MemoryCard] {
        let icons = CraftIconLoader.registeredMaterialIDs.shuffled()
        let selected = Array(icons.prefix(pairCount))
        let itemIDs = (selected + selected).shuffled()

        return itemIDs.map { itemID in
            MemoryCard(id: UUID(), itemID: itemID, isFaceUp: false, isMatched: false)
        }
    }
}
