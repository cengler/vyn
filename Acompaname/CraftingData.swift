import Foundation

enum GameMode: String, CaseIterable, Identifiable {
    case minecraft
    case crafting
    case memory
    case taboo
    case merge2048

    var id: String { rawValue }

    var title: String { L10n.modeTitle(self) }

    var subtitle: String { L10n.modeSubtitle(self) }

    var isWordSearch: Bool {
        self == .minecraft
    }

    var wordSearchTheme: WordTheme? {
        switch self {
        case .minecraft: .minecraft
        case .crafting, .memory, .taboo, .merge2048: nil
        }
    }
}

private struct CraftingDataset: Decodable {
    let sessionSize: Int?
    let recipes: [CraftRecipe]

    enum CodingKeys: String, CodingKey {
        case sessionSize = "session_size"
        case recipes
    }
}

struct CraftRecipe: Identifiable, Decodable {
    let result: String
    let pattern: [[String?]]
    let note: String

    var id: String { result }

    var requiredMaterials: Set<String> {
        Set(pattern.flatMap { $0 }.compactMap { $0 })
    }

    var displayName: String { L10n.item(result) }

    func materialOptions() -> [String] {
        var options = Array(requiredMaterials)
        for extra in CraftingCatalog.decoys.shuffled() where options.count < 6 {
            if !options.contains(extra) {
                options.append(extra)
            }
        }
        return options.shuffled()
    }
}

enum CraftingCatalog {
    private static let storage = Storage()

    static var recipes: [CraftRecipe] { storage.dataset.recipes }
    static var decoys: [String] { CraftIconLoader.registeredMaterialIDs }
    static var sessionSize: Int { storage.sessionSize }
    static var loadIssue: String? { storage.loadIssue }

    static func randomSession() -> [CraftRecipe] {
        guard !recipes.isEmpty else { return [] }
        let count = min(sessionSize, recipes.count)
        return Array(recipes.shuffled().prefix(count))
    }

    static func recipe(for result: String) -> CraftRecipe? {
        recipes.first { $0.result == result }
    }

    private final class Storage: @unchecked Sendable {
        private let lock = NSLock()
        private var cachedDataset: CraftingDataset?
        private var cachedSessionSize = 5
        private(set) var loadIssue: String?

        var dataset: CraftingDataset {
            lock.lock()
            defer { lock.unlock() }
            if let cachedDataset {
                return cachedDataset
            }
            let loaded = Self.loadDataset()
            cachedDataset = loaded.dataset
            cachedSessionSize = loaded.sessionSize
            loadIssue = loaded.issue
            return loaded.dataset
        }

        var sessionSize: Int {
            _ = dataset
            lock.lock()
            defer { lock.unlock() }
            return cachedSessionSize
        }

        private static func loadDataset() -> (dataset: CraftingDataset, sessionSize: Int, issue: String?) {
            guard let url = Bundle.main.url(forResource: "crafting_recipes", withExtension: "json") else {
                return (
                    CraftingDataset(sessionSize: 5, recipes: []),
                    5,
                    L10n.craftingLoadMissing
                )
            }

            guard let data = try? Data(contentsOf: url) else {
                return (
                    CraftingDataset(sessionSize: 5, recipes: []),
                    5,
                    L10n.craftingLoadUnreadable
                )
            }

            do {
                let decoded = try JSONDecoder().decode(CraftingDataset.self, from: data)
                guard !decoded.recipes.isEmpty else {
                    return (
                        CraftingDataset(sessionSize: 5, recipes: []),
                        5,
                        L10n.craftingLoadEmpty
                    )
                }
                return (decoded, max(1, decoded.sessionSize ?? 5), nil)
            } catch {
                return (
                    CraftingDataset(sessionSize: 5, recipes: []),
                    5,
                    L10n.craftingLoadInvalid
                )
            }
        }
    }
}

enum CraftIconPalette {
    static func color(for id: String) -> (red: Double, green: Double, blue: Double) {
        if id.hasPrefix("iron_") || id == "iron_ingot" {
            return (0.78, 0.78, 0.82)
        }
        if id.hasPrefix("diamond_") || id == "diamond" {
            return (0.35, 0.90, 0.86)
        }
        if id.hasPrefix("golden_") || id.hasPrefix("gold_") {
            return (0.86, 0.75, 0.35)
        }
        if id.hasPrefix("copper_") || id == "copper_ingot" {
            return (0.78, 0.47, 0.27)
        }
        if id.hasPrefix("wooden_") || id.contains("planks") || id.contains("log") || id == "stick" || id == "crafting_table" || id == "chest" {
            return (0.55, 0.35, 0.17)
        }
        if id.hasPrefix("stone_") || id.contains("cobblestone") || id == "furnace" {
            return (0.51, 0.51, 0.51)
        }
        if id.contains("redstone") {
            return (0.71, 0.08, 0.08)
        }
        if id.contains("torch") {
            return (1.0, 0.39, 0.08)
        }
        if id == "coal" {
            return (0.16, 0.16, 0.16)
        }
        if id == "chest" {
            return (0.55, 0.35, 0.17)
        }
        return (0.45, 0.45, 0.50)
    }
}
