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
    static let craftingLoadFallback = String(localized: "crafting.load.fallback")
    static let craftingLoadError = String(localized: "crafting.load.error")

    static func modeTitle(_ mode: GameMode) -> String {
        switch mode {
        case .random: String(localized: "mode.random.title")
        case .minecraft: String(localized: "mode.minecraft.title")
        case .crafting: String(localized: "mode.crafting.title")
        }
    }

    static func modeSubtitle(_ mode: GameMode) -> String {
        switch mode {
        case .random: String(localized: "mode.random.subtitle")
        case .minecraft: String(localized: "mode.minecraft.subtitle")
        case .crafting: String(localized: "mode.crafting.subtitle")
        }
    }

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
