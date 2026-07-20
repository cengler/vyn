import Foundation

enum CraftingRecipesFallback {
    static let data = Data(embedded.utf8)

    private static let embedded = """
    {
      "session_size": 5,
      "decoys": [
        "diamond",
        "copper_ingot",
        "iron_pickaxe",
        "iron_sword",
        "furnace",
        "chest",
        "torch",
        "redstone_dust",
        "ladder",
        "oak_log"
      ],
      "recipes": [
        {
          "result": "iron_pickaxe",
          "note": "Pico de hierro",
          "pattern": [
            ["iron_ingot", "iron_ingot", "iron_ingot"],
            [null, "stick", null],
            [null, "stick", null]
          ]
        },
        {
          "result": "iron_axe",
          "note": "Hacha de hierro",
          "pattern": [
            ["iron_ingot", "iron_ingot", null],
            ["iron_ingot", "stick", null],
            [null, "stick", null]
          ]
        },
        {
          "result": "iron_sword",
          "note": "Espada de hierro",
          "pattern": [
            [null, "iron_ingot", null],
            [null, "iron_ingot", null],
            [null, "stick", null]
          ]
        },
        {
          "result": "iron_shovel",
          "note": "Pala de hierro",
          "pattern": [
            [null, "iron_ingot", null],
            [null, "stick", null],
            [null, "stick", null]
          ]
        },
        {
          "result": "iron_hoe",
          "note": "Azada de hierro",
          "pattern": [
            ["iron_ingot", "iron_ingot", null],
            [null, "stick", null],
            [null, "stick", null]
          ]
        },
        {
          "result": "wooden_pickaxe",
          "note": "Pico de madera",
          "pattern": [
            ["oak_planks", "oak_planks", "oak_planks"],
            [null, "stick", null],
            [null, "stick", null]
          ]
        },
        {
          "result": "wooden_axe",
          "note": "Hacha de madera",
          "pattern": [
            ["oak_planks", "oak_planks", null],
            ["oak_planks", "stick", null],
            [null, "stick", null]
          ]
        },
        {
          "result": "wooden_sword",
          "note": "Espada de madera",
          "pattern": [
            [null, "oak_planks", null],
            [null, "oak_planks", null],
            [null, "stick", null]
          ]
        },
        {
          "result": "wooden_shovel",
          "note": "Pala de madera",
          "pattern": [
            [null, "oak_planks", null],
            [null, "stick", null],
            [null, "stick", null]
          ]
        },
        {
          "result": "wooden_hoe",
          "note": "Azada de madera",
          "pattern": [
            ["oak_planks", "oak_planks", null],
            [null, "stick", null],
            [null, "stick", null]
          ]
        },
        {
          "result": "stone_pickaxe",
          "note": "Pico de piedra",
          "pattern": [
            ["cobblestone", "cobblestone", "cobblestone"],
            [null, "stick", null],
            [null, "stick", null]
          ]
        },
        {
          "result": "stone_axe",
          "note": "Hacha de piedra",
          "pattern": [
            ["cobblestone", "cobblestone", null],
            ["cobblestone", "stick", null],
            [null, "stick", null]
          ]
        },
        {
          "result": "stone_sword",
          "note": "Espada de piedra",
          "pattern": [
            [null, "cobblestone", null],
            [null, "cobblestone", null],
            [null, "stick", null]
          ]
        },
        {
          "result": "stone_shovel",
          "note": "Pala de piedra",
          "pattern": [
            [null, "cobblestone", null],
            [null, "stick", null],
            [null, "stick", null]
          ]
        },
        {
          "result": "stone_hoe",
          "note": "Azada de piedra",
          "pattern": [
            ["cobblestone", "cobblestone", null],
            [null, "stick", null],
            [null, "stick", null]
          ]
        },
        {
          "result": "torch",
          "note": "Antorcha",
          "pattern": [
            [null, "coal", null],
            [null, "stick", null],
            [null, null, null]
          ]
        },
        {
          "result": "stick",
          "note": "Palo",
          "pattern": [
            [null, "oak_planks", null],
            [null, "oak_planks", null],
            [null, null, null]
          ]
        },
        {
          "result": "oak_planks",
          "note": "Tablas de roble",
          "pattern": [
            [null, "oak_log", null],
            [null, null, null],
            [null, null, null]
          ]
        },
        {
          "result": "crafting_table",
          "note": "Mesa de crafteo",
          "pattern": [
            ["oak_planks", "oak_planks", null],
            ["oak_planks", "oak_planks", null],
            [null, null, null]
          ]
        },
        {
          "result": "chest",
          "note": "Cofre",
          "pattern": [
            ["oak_planks", "oak_planks", "oak_planks"],
            ["oak_planks", null, "oak_planks"],
            ["oak_planks", "oak_planks", "oak_planks"]
          ]
        }
      ]
    }
    """
}
