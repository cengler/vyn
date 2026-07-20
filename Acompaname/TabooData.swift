import Foundation

struct TabooCard: Identifiable, Equatable {
    let id: String
    let word: String
    let forbidden: [String]
}

enum TabooDeck {
    static let cards: [TabooCard] = [
        TabooCard(id: "creeper", word: "CREEPER", forbidden: ["VERDE", "EXPLOSIÓN", "MOB", "SSSS"]),
        TabooCard(id: "zombie", word: "ZOMBIE", forbidden: ["VERDE", "NOCHE", "MOB", "BRAZOS"]),
        TabooCard(id: "esqueleto", word: "ESQUELETO", forbidden: ["HUESOS", "ARCO", "FLECHA", "BLANCO"]),
        TabooCard(id: "steve", word: "STEVE", forbidden: ["JUGADOR", "SKIN", "ALDEANO", "PERSONAJE"]),
        TabooCard(id: "diamante", word: "DIAMANTE", forbidden: ["AZUL", "MINERAL", "PICO", "RARO"]),
        TabooCard(id: "hierro", word: "HIERRO", forbidden: ["LINGOTE", "MINERAL", "ARMADURA", "METAL"]),
        TabooCard(id: "carbon", word: "CARBÓN", forbidden: ["NEGRO", "MINERAL", "ANTORCHA", "COMBUSTIBLE"]),
        TabooCard(id: "pico", word: "PICO", forbidden: ["MINAR", "HERRAMIENTA", "PIEDRA", "MANO"]),
        TabooCard(id: "espada", word: "ESPADA", forbidden: ["PELEAR", "HERRAMIENTA", "MOB", "GOLPEAR"]),
        TabooCard(id: "arco", word: "ARCO", forbidden: ["FLECHA", "DISPARAR", "ESQUELETO", "CUERDA"]),
        TabooCard(id: "antorcha", word: "ANTORCHA", forbidden: ["LUZ", "CARBÓN", "PALO", "OSCURIDAD"]),
        TabooCard(id: "cofre", word: "COFRE", forbidden: ["GUARDAR", "MADERA", "OBJETOS", "ABRIR"]),
        TabooCard(id: "forja", word: "FORJA", forbidden: ["FUNDIR", "HIERRO", "COCINAR", "PIEDRA"]),
        TabooCard(id: "portal", word: "PORTAL", forbidden: ["NETHER", "OBSIDIAN", "VIAJAR", "FUEGO"]),
        TabooCard(id: "nether", word: "NETHER", forbidden: ["INFIERNO", "PORTAL", "LAVA", "DIMENSIÓN"]),
        TabooCard(id: "ender", word: "ENDER", forbidden: ["DRAGÓN", "PERLA", "OJO", "FIN"]),
        TabooCard(id: "obsidian", word: "OBSIDIAN", forbidden: ["NEGRO", "LAVA", "AGUA", "PORTAL"]),
        TabooCard(id: "redstone", word: "REDSTONE", forbidden: ["ROJO", "POLVO", "CIRCUITO", "PALANCA"]),
        TabooCard(id: "vaca", word: "VACA", forbidden: ["LECHE", "ANIMAL", "CARNE", "GRANJA"]),
        TabooCard(id: "cerdo", word: "CERDO", forbidden: ["ANIMAL", "CARNE", "ROSA", "GRANJA"]),
        TabooCard(id: "lobo", word: "LOBO", forbidden: ["PERRO", "ANIMAL", "AULLAR", "COLA"]),
        TabooCard(id: "golem", word: "GOLEM", forbidden: ["HIERRO", "ALDEA", "PROTEGER", "CALABAZA"]),
        TabooCard(id: "aldea", word: "ALDEA", forbidden: ["ALDEANO", "CASA", "COMERCIO", "PUEBLO"]),
        TabooCard(id: "cueva", word: "CUEVA", forbidden: ["MINAR", "OSCURIDAD", "PIEDRA", "SUBTERRÁNEO"]),
        TabooCard(id: "lava", word: "LAVA", forbidden: ["FUEGO", "ROJO", "QUEMAR", "NETHER"]),
        TabooCard(id: "nieve", word: "NIEVE", forbidden: ["FRÍO", "BLANCO", "HIELO", "BIOMA"]),
        TabooCard(id: "madera", word: "MADERA", forbidden: ["ÁRBOL", "TRONCO", "TABLA", "BOSQUE"]),
        TabooCard(id: "trigo", word: "TRIGO", forbidden: ["GRANJA", "PAN", "SEMILLA", "AMARILLO"]),
        TabooCard(id: "brujula", word: "BRÚJULA", forbidden: ["DIRECCIÓN", "SPAWN", "AGUJA", "ORIENTAR"]),
        TabooCard(id: "cristal", word: "CRISTAL", forbidden: ["VIDRIO", "TRANSPARENTE", "ARENA", "LÁMPARA"]),
        TabooCard(id: "cobre", word: "COBRE", forbidden: ["NARANJA", "MINERAL", "LINGOTE", "METAL"]),
        TabooCard(id: "esmeralda", word: "ESMERALDA", forbidden: ["VERDE", "MINERAL", "ALDEANO", "COMERCIO"]),
    ]

    static func shuffledDeck() -> [TabooCard] {
        cards.shuffled()
    }
}

enum TabooSession {
    static func nextCard(after index: Int, in deck: [TabooCard]) -> (card: TabooCard, index: Int) {
        guard !deck.isEmpty else {
            return (TabooCard(id: "empty", word: "—", forbidden: ["—", "—", "—", "—"]), 0)
        }

        let nextIndex = (index + 1) % deck.count
        return (deck[nextIndex], nextIndex)
    }
}
