import Foundation

enum L10n {
    static let appTitle = String(localized: "app.title")
    static let chooseMode = String(localized: "menu.choose_mode")
    static let menuAttribution = String(localized: "menu.attribution")

    static let wordSearchVictoryTitle = String(localized: "wordsearch.victory.title")
    static let wordSearchVictorySubtitle = String(localized: "wordsearch.victory.subtitle")
    static let wordSearchVictoryAction = String(localized: "wordsearch.victory.action")

    static let craftingLoading = String(localized: "crafting.loading")
    static let craftingUnavailable = String(localized: "crafting.unavailable")
    static let craftingAction = String(localized: "crafting.action")
    static let craftingTable = String(localized: "crafting.table")
    static let craftingPickMaterial = String(localized: "crafting.pick_material")
    static let craftingInstruction = String(localized: "crafting.instruction")
    static let craftingVictoryTitle = String(localized: "crafting.victory.title")
    static let craftingVictoryAction = String(localized: "crafting.victory.action")
    static let craftingAttribution = String(localized: "crafting.attribution")
    static let craftingLoadMissing = String(localized: "crafting.load.missing")
    static let craftingLoadUnreadable = String(localized: "crafting.load.unreadable")
    static let craftingLoadEmpty = String(localized: "crafting.load.empty")
    static let craftingLoadInvalid = String(localized: "crafting.load.invalid")

    static let memoryInstruction = String(localized: "memory.instruction")
    static let memoryVictoryTitle = String(localized: "memory.victory.title")
    static let memoryVictoryAction = String(localized: "memory.victory.action")

    static func memoryPairsProgress(matched: Int, total: Int) -> String {
        String(localized: "memory.pairs \(matched) \(total)")
    }

    static func memoryMoves(_ moves: Int) -> String {
        String(localized: "memory.moves \(moves)")
    }

    static func memoryVictorySubtitle(moves: Int) -> String {
        String(localized: "memory.victory.subtitle \(moves)")
    }

    static func modeTitle(_ mode: GameMode) -> String {
        switch mode {
        case .minecraft: String(localized: "mode.minecraft.title")
        case .crafting: String(localized: "mode.crafting.title")
        case .memory: String(localized: "mode.memory.title")
        case .taboo: String(localized: "mode.taboo.title")
        case .merge2048: String(localized: "mode.merge2048.title")
        }
    }

    static func modeSubtitle(_ mode: GameMode) -> String {
        switch mode {
        case .minecraft: String(localized: "mode.minecraft.subtitle")
        case .crafting: String(localized: "mode.crafting.subtitle")
        case .memory: String(localized: "mode.memory.subtitle")
        case .taboo: String(localized: "mode.taboo.subtitle")
        case .merge2048: String(localized: "mode.merge2048.subtitle")
        }
    }

    static let mergeInstruction = String(localized: "merge2048.instruction")
    static let mergeVictoryTitle = String(localized: "merge2048.victory.title")
    static let mergeVictorySubtitle = String(localized: "merge2048.victory.subtitle")
    static let mergeVictoryAction = String(localized: "merge2048.victory.action")
    static let mergeGameOverTitle = String(localized: "merge2048.gameover.title")
    static let mergeGameOverAction = String(localized: "merge2048.gameover.action")

    static func mergeScore(_ score: Int) -> String {
        String(localized: "merge2048.score \(score)")
    }

    static let tabooInstruction = String(localized: "taboo.instruction")
    static let tabooForbiddenTitle = String(localized: "taboo.forbidden_title")
    static let tabooSuccess = String(localized: "taboo.success")
    static let tabooFailure = String(localized: "taboo.failure")
    static let tabooSuccessLabel = String(localized: "taboo.success_label")
    static let tabooFailureLabel = String(localized: "taboo.failure_label")

    static func craftingVictorySubtitle(count: Int) -> String {
        String(localized: "crafting.victory.subtitle \(count)")
    }

    static func item(_ id: String) -> String {
        let key = "item.\(id)"
        let translated = Bundle.main.localizedString(forKey: key, value: nil, table: nil)
        guard translated != key else {
            return id
                .split(separator: "_")
                .map { $0.capitalized }
                .joined(separator: " ")
        }
        return translated
    }
}
