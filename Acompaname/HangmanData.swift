import Foundation

struct HangmanRound: Identifiable, Equatable {
    let id: String
    let word: String
    let hint: String
}

enum HangmanCatalog {
    static let maxWrongGuesses = 6

    static let rounds: [HangmanRound] = [
        HangmanRound(id: "creeper", word: "CREEPER", hint: "Mob verde que explota"),
        HangmanRound(id: "zombie", word: "ZOMBIE", hint: "Mob que aparece de noche"),
        HangmanRound(id: "esqueleto", word: "ESQUELETO", hint: "Mob que dispara flechas"),
        HangmanRound(id: "espada", word: "ESPADA", hint: "Arma para combatir"),
        HangmanRound(id: "pico", word: "PICO", hint: "Herramienta para minar"),
        HangmanRound(id: "diamante", word: "DIAMANTE", hint: "Mineral más valioso"),
        HangmanRound(id: "hierro", word: "HIERRO", hint: "Metal gris muy útil"),
        HangmanRound(id: "carbon", word: "CARBON", hint: "Mineral negro combustible"),
        HangmanRound(id: "redstone", word: "REDSTONE", hint: "Polvo rojo eléctrico"),
        HangmanRound(id: "obsidian", word: "OBSIDIAN", hint: "Bloque negro del portal"),
        HangmanRound(id: "portal", word: "PORTAL", hint: "Viaje al Nether"),
        HangmanRound(id: "nether", word: "NETHER", hint: "Dimensión de lava"),
        HangmanRound(id: "cofre", word: "COFRE", hint: "Guarda objetos"),
        HangmanRound(id: "forja", word: "FORJA", hint: "Funde minerales"),
        HangmanRound(id: "antorcha", word: "ANTORCHA", hint: "Da luz en las cuevas"),
        HangmanRound(id: "arco", word: "ARCO", hint: "Dispara flechas"),
        HangmanRound(id: "vaca", word: "VACA", hint: "Animal que da leche"),
        HangmanRound(id: "lobo", word: "LOBO", hint: "Animal que puede aullar"),
        HangmanRound(id: "golem", word: "GOLEM", hint: "Gigante que protege aldeas"),
        HangmanRound(id: "brujula", word: "BRUJULA", hint: "Marca la dirección del spawn"),
        HangmanRound(id: "esmeralda", word: "ESMERALDA", hint: "Mineral verde de comercio"),
        HangmanRound(id: "cristal", word: "CRISTAL", hint: "Bloque transparente"),
        HangmanRound(id: "nieve", word: "NIEVE", hint: "Cae en biomas fríos"),
        HangmanRound(id: "lava", word: "LAVA", hint: "Líquido ardiente rojo"),
        HangmanRound(id: "steve", word: "STEVE", hint: "Jugador clásico"),
        HangmanRound(id: "trigo", word: "TRIGO", hint: "Cultivo amarillo de granja"),
        HangmanRound(id: "arena", word: "ARENA", hint: "Bloque del desierto"),
        HangmanRound(id: "ender", word: "ENDER", hint: "Dragón del fin del juego"),
        HangmanRound(id: "cofre2", word: "BLOQUE", hint: "Unidad básica del mundo"),
        HangmanRound(id: "madera", word: "MADERA", hint: "Viene de los árboles"),
    ]

    static func randomRound(excluding excludedID: String? = nil) -> HangmanRound {
        let pool = rounds.filter { $0.id != excludedID }
        return (pool.isEmpty ? rounds : pool).randomElement() ?? rounds[0]
    }

    static func normalizeLetter(_ letter: Character) -> Character {
        let normalized = String(letter)
            .uppercased()
            .folding(options: .diacriticInsensitive, locale: Locale(identifier: "es"))
        return normalized.first ?? letter
    }

    static func normalizedWord(_ word: String) -> String {
        word
            .uppercased()
            .folding(options: .diacriticInsensitive, locale: Locale(identifier: "es"))
    }
}
