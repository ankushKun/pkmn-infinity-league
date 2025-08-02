extends Node

enum TYPES {
	NORMAL,
	FIRE,
	WATER,
	ELECTRIC,
	GRASS,
	ICE,
	FIGHTING,
	POISON,
	GROUND,
	FLYING,
	PSYCHIC,
	BUG,
	ROCK,
	GHOST,
	DRAGON,
	DARK,
	STEEL,
	FAIRY
}

# Comprehensive type effectiveness chart based on the provided image
# Each entry is [attacking_type][defending_type] = multiplier
const TYPE_EFFECTIVENESS_CHART = {
	TYPES.BUG: {
		TYPES.BUG: 1.25, TYPES.DARK: 1.0, TYPES.DRAGON: 1.0, TYPES.ELECTRIC: 1.0,
		TYPES.FAIRY: 0.8, TYPES.FIGHTING: 0.8, TYPES.FIRE: 0.8, TYPES.FLYING: 0.8,
		TYPES.GHOST: 0.8, TYPES.GRASS: 1.25, TYPES.GROUND: 1.0, TYPES.ICE: 1.0,
		TYPES.NORMAL: 1.0, TYPES.POISON: 0.8, TYPES.PSYCHIC: 1.25, TYPES.ROCK: 1.0,
		TYPES.STEEL: 0.8, TYPES.WATER: 1.0
	},
	TYPES.DARK: {
		TYPES.BUG: 1.0, TYPES.DARK: 0.8, TYPES.DRAGON: 1.0, TYPES.ELECTRIC: 1.0,
		TYPES.FAIRY: 0.8, TYPES.FIGHTING: 0.8, TYPES.FIRE: 1.0, TYPES.FLYING: 1.0,
		TYPES.GHOST: 1.25, TYPES.GRASS: 1.0, TYPES.GROUND: 1.0, TYPES.ICE: 1.0,
		TYPES.NORMAL: 1.0, TYPES.POISON: 1.0, TYPES.PSYCHIC: 1.25, TYPES.ROCK: 1.0,
		TYPES.STEEL: 0.8, TYPES.WATER: 1.0
	},
	TYPES.DRAGON: {
		TYPES.BUG: 1.0, TYPES.DARK: 1.0, TYPES.DRAGON: 1.25, TYPES.ELECTRIC: 1.0,
		TYPES.FAIRY: 0.8, TYPES.FIGHTING: 1.0, TYPES.FIRE: 1.0, TYPES.FLYING: 1.0,
		TYPES.GHOST: 1.0, TYPES.GRASS: 1.0, TYPES.GROUND: 1.0, TYPES.ICE: 1.0,
		TYPES.NORMAL: 1.0, TYPES.POISON: 1.0, TYPES.PSYCHIC: 1.0, TYPES.ROCK: 1.0,
		TYPES.STEEL: 0.8, TYPES.WATER: 1.0
	},
	TYPES.ELECTRIC: {
		TYPES.BUG: 1.0, TYPES.DARK: 1.0, TYPES.DRAGON: 0.8, TYPES.ELECTRIC: 0.8,
		TYPES.FAIRY: 1.0, TYPES.FIGHTING: 1.0, TYPES.FIRE: 1.0, TYPES.FLYING: 1.25,
		TYPES.GHOST: 1.0, TYPES.GRASS: 0.8, TYPES.GROUND: 0.8, TYPES.ICE: 1.0,
		TYPES.NORMAL: 1.0, TYPES.POISON: 1.0, TYPES.PSYCHIC: 1.0, TYPES.ROCK: 1.0,
		TYPES.STEEL: 1.0, TYPES.WATER: 1.25
	},
	TYPES.FAIRY: {
		TYPES.BUG: 1.25, TYPES.DARK: 1.25, TYPES.DRAGON: 1.0, TYPES.ELECTRIC: 1.0,
		TYPES.FAIRY: 1.0, TYPES.FIGHTING: 1.25, TYPES.FIRE: 0.8, TYPES.FLYING: 1.0,
		TYPES.GHOST: 1.0, TYPES.GRASS: 1.0, TYPES.GROUND: 1.0, TYPES.ICE: 1.0,
		TYPES.NORMAL: 1.0, TYPES.POISON: 0.8, TYPES.PSYCHIC: 1.0, TYPES.ROCK: 1.0,
		TYPES.STEEL: 0.8, TYPES.WATER: 1.0
	},
	TYPES.FIGHTING: {
		TYPES.BUG: 0.8, TYPES.DARK: 1.25, TYPES.DRAGON: 1.0, TYPES.ELECTRIC: 1.0,
		TYPES.FAIRY: 0.8, TYPES.FIGHTING: 1.0, TYPES.FIRE: 1.0, TYPES.FLYING: 0.8,
		TYPES.GHOST: 0.8, TYPES.GRASS: 1.0, TYPES.GROUND: 1.0, TYPES.ICE: 1.25,
		TYPES.NORMAL: 1.25, TYPES.POISON: 0.8, TYPES.PSYCHIC: 0.8, TYPES.ROCK: 1.25,
		TYPES.STEEL: 1.25, TYPES.WATER: 1.25
	},
	TYPES.FIRE: {
		TYPES.BUG: 1.25, TYPES.DARK: 1.0, TYPES.DRAGON: 0.8, TYPES.ELECTRIC: 1.0,
		TYPES.FAIRY: 1.0, TYPES.FIGHTING: 1.0, TYPES.FIRE: 0.8, TYPES.FLYING: 1.0,
		TYPES.GHOST: 1.0, TYPES.GRASS: 1.25, TYPES.GROUND: 1.0, TYPES.ICE: 1.25,
		TYPES.NORMAL: 1.0, TYPES.POISON: 1.0, TYPES.PSYCHIC: 1.0, TYPES.ROCK: 0.8,
		TYPES.STEEL: 1.25, TYPES.WATER: 0.8
	},
	TYPES.FLYING: {
		TYPES.BUG: 1.25, TYPES.DARK: 1.0, TYPES.DRAGON: 1.0, TYPES.ELECTRIC: 0.8,
		TYPES.FAIRY: 1.0, TYPES.FIGHTING: 1.25, TYPES.FIRE: 1.0, TYPES.FLYING: 1.0,
		TYPES.GHOST: 1.0, TYPES.GRASS: 1.25, TYPES.GROUND: 1.0, TYPES.ICE: 1.0,
		TYPES.NORMAL: 1.0, TYPES.POISON: 1.0, TYPES.PSYCHIC: 1.0, TYPES.ROCK: 0.8,
		TYPES.STEEL: 0.8, TYPES.WATER: 1.0
	},
	TYPES.GHOST: {
		TYPES.BUG: 1.0, TYPES.DARK: 0.8, TYPES.DRAGON: 1.0, TYPES.ELECTRIC: 1.0,
		TYPES.FAIRY: 1.0, TYPES.FIGHTING: 1.0, TYPES.FIRE: 1.0, TYPES.FLYING: 1.0,
		TYPES.GHOST: 1.25, TYPES.GRASS: 1.0, TYPES.GROUND: 1.0, TYPES.ICE: 1.0,
		TYPES.NORMAL: 0.8, TYPES.POISON: 1.0, TYPES.PSYCHIC: 1.25, TYPES.ROCK: 1.0,
		TYPES.STEEL: 1.0, TYPES.WATER: 1.0
	},
	TYPES.GRASS: {
		TYPES.BUG: 0.8, TYPES.DARK: 1.0, TYPES.DRAGON: 0.8, TYPES.ELECTRIC: 1.0,
		TYPES.FAIRY: 1.0, TYPES.FIGHTING: 1.0, TYPES.FIRE: 0.8, TYPES.FLYING: 0.8,
		TYPES.GHOST: 1.0, TYPES.GRASS: 0.8, TYPES.GROUND: 1.25, TYPES.ICE: 1.0,
		TYPES.NORMAL: 1.0, TYPES.POISON: 0.8, TYPES.PSYCHIC: 1.0, TYPES.ROCK: 1.25,
		TYPES.STEEL: 0.8, TYPES.WATER: 1.25
	},
	TYPES.GROUND: {
		TYPES.BUG: 0.8, TYPES.DARK: 1.0, TYPES.DRAGON: 1.0, TYPES.ELECTRIC: 1.25,
		TYPES.FAIRY: 1.0, TYPES.FIGHTING: 1.0, TYPES.FIRE: 1.25, TYPES.FLYING: 0.8,
		TYPES.GHOST: 1.0, TYPES.GRASS: 0.8, TYPES.GROUND: 1.0, TYPES.ICE: 1.0,
		TYPES.NORMAL: 1.0, TYPES.POISON: 1.25, TYPES.PSYCHIC: 1.0, TYPES.ROCK: 1.25,
		TYPES.STEEL: 1.25, TYPES.WATER: 1.0
	},
	TYPES.ICE: {
		TYPES.BUG: 1.0, TYPES.DARK: 1.0, TYPES.DRAGON: 1.25, TYPES.ELECTRIC: 1.0,
		TYPES.FAIRY: 1.0, TYPES.FIGHTING: 1.0, TYPES.FIRE: 0.8, TYPES.FLYING: 1.25,
		TYPES.GHOST: 1.0, TYPES.GRASS: 1.25, TYPES.GROUND: 1.0, TYPES.ICE: 0.8,
		TYPES.NORMAL: 1.0, TYPES.POISON: 1.0, TYPES.PSYCHIC: 1.0, TYPES.ROCK: 1.0,
		TYPES.STEEL: 0.8, TYPES.WATER: 0.8
	},
	TYPES.NORMAL: {
		TYPES.BUG: 1.0, TYPES.DARK: 1.0, TYPES.DRAGON: 1.0, TYPES.ELECTRIC: 1.0,
		TYPES.FAIRY: 1.0, TYPES.FIGHTING: 1.0, TYPES.FIRE: 1.0, TYPES.FLYING: 1.0,
		TYPES.GHOST: 0.8, TYPES.GRASS: 1.0, TYPES.GROUND: 1.0, TYPES.ICE: 1.0,
		TYPES.NORMAL: 1.0, TYPES.POISON: 1.0, TYPES.PSYCHIC: 1.0, TYPES.ROCK: 0.8,
		TYPES.STEEL: 0.8, TYPES.WATER: 1.0
	},
	TYPES.POISON: {
		TYPES.BUG: 1.0, TYPES.DARK: 1.0, TYPES.DRAGON: 1.0, TYPES.ELECTRIC: 1.0,
		TYPES.FAIRY: 1.25, TYPES.FIGHTING: 1.0, TYPES.FIRE: 1.0, TYPES.FLYING: 1.0,
		TYPES.GHOST: 0.8, TYPES.GRASS: 1.0, TYPES.GROUND: 1.25, TYPES.ICE: 1.0,
		TYPES.NORMAL: 1.0, TYPES.POISON: 0.8, TYPES.PSYCHIC: 1.0, TYPES.ROCK: 0.8,
		TYPES.STEEL: 0.8, TYPES.WATER: 1.0
	},
	TYPES.PSYCHIC: {
		TYPES.BUG: 1.0, TYPES.DARK: 0.8, TYPES.DRAGON: 1.0, TYPES.ELECTRIC: 1.0,
		TYPES.FAIRY: 1.0, TYPES.FIGHTING: 1.25, TYPES.FIRE: 1.0, TYPES.FLYING: 1.0,
		TYPES.GHOST: 1.0, TYPES.GRASS: 1.0, TYPES.GROUND: 1.0, TYPES.ICE: 1.0,
		TYPES.NORMAL: 1.0, TYPES.POISON: 1.0, TYPES.PSYCHIC: 1.25, TYPES.ROCK: 1.0,
		TYPES.STEEL: 0.8, TYPES.WATER: 1.0
	},
	TYPES.ROCK: {
		TYPES.BUG: 1.25, TYPES.DARK: 1.0, TYPES.DRAGON: 1.0, TYPES.ELECTRIC: 1.0,
		TYPES.FAIRY: 1.0, TYPES.FIGHTING: 0.8, TYPES.FIRE: 1.25, TYPES.FLYING: 1.25,
		TYPES.GHOST: 1.0, TYPES.GRASS: 1.0, TYPES.GROUND: 1.25, TYPES.ICE: 1.0,
		TYPES.NORMAL: 1.0, TYPES.POISON: 1.0, TYPES.PSYCHIC: 1.0, TYPES.ROCK: 0.8,
		TYPES.STEEL: 0.8, TYPES.WATER: 0.8
	},
	TYPES.STEEL: {
		TYPES.BUG: 1.0, TYPES.DARK: 1.0, TYPES.DRAGON: 1.0, TYPES.ELECTRIC: 0.8,
		TYPES.FAIRY: 1.25, TYPES.FIGHTING: 1.0, TYPES.FIRE: 0.8, TYPES.FLYING: 1.0,
		TYPES.GHOST: 1.0, TYPES.GRASS: 1.0, TYPES.GROUND: 1.0, TYPES.ICE: 1.25,
		TYPES.NORMAL: 1.0, TYPES.POISON: 1.0, TYPES.PSYCHIC: 1.0, TYPES.ROCK: 1.25,
		TYPES.STEEL: 0.8, TYPES.WATER: 0.8
	},
	TYPES.WATER: {
		TYPES.BUG: 1.0, TYPES.DARK: 1.0, TYPES.DRAGON: 0.8, TYPES.ELECTRIC: 0.8,
		TYPES.FAIRY: 1.0, TYPES.FIGHTING: 1.0, TYPES.FIRE: 1.25, TYPES.FLYING: 1.0,
		TYPES.GHOST: 1.0, TYPES.GRASS: 0.8, TYPES.GROUND: 1.25, TYPES.ICE: 1.0,
		TYPES.NORMAL: 1.0, TYPES.POISON: 1.0, TYPES.PSYCHIC: 1.0, TYPES.ROCK: 1.25,
		TYPES.STEEL: 1.0, TYPES.WATER: 0.8
	}
}

func get_type_effectiveness(attacking_type: TYPES, defending_type: TYPES) -> float:
	"""Get the type effectiveness multiplier based on the comprehensive chart."""
	if attacking_type in TYPE_EFFECTIVENESS_CHART and defending_type in TYPE_EFFECTIVENESS_CHART[attacking_type]:
		return TYPE_EFFECTIVENESS_CHART[attacking_type][defending_type]
	return 1.0

func TypeIsWeakAgainst(typeA: TYPES, typeB: TYPES) -> bool:
	"""Returns true if typeA is weak against typeB (0.8x multiplier)."""
	return get_type_effectiveness(typeA, typeB) < 1.0

func TypeIsStrongAgainst(typeA: TYPES, typeB: TYPES) -> bool:
	"""Returns true if typeA is strong against typeB (1.25x multiplier)."""
	return get_type_effectiveness(typeA, typeB) > 1.0

func test_type_effectiveness() -> void:
	"""Test and display all type effectiveness relationships for verification."""
	print("=== TYPE EFFECTIVENESS TEST ===")
	
	var types = [TYPES.NORMAL, TYPES.FIRE, TYPES.WATER, TYPES.ELECTRIC, TYPES.GRASS,
				 TYPES.ICE, TYPES.FIGHTING, TYPES.POISON, TYPES.GROUND, TYPES.FLYING,
				 TYPES.PSYCHIC, TYPES.BUG, TYPES.ROCK, TYPES.GHOST, TYPES.DRAGON,
				 TYPES.DARK, TYPES.STEEL, TYPES.FAIRY]
	
	var type_names = {
		TYPES.NORMAL: "Normal", TYPES.FIRE: "Fire", TYPES.WATER: "Water",
		TYPES.ELECTRIC: "Electric", TYPES.GRASS: "Grass", TYPES.ICE: "Ice",
		TYPES.FIGHTING: "Fighting", TYPES.POISON: "Poison", TYPES.GROUND: "Ground",
		TYPES.FLYING: "Flying", TYPES.PSYCHIC: "Psychic", TYPES.BUG: "Bug",
		TYPES.ROCK: "Rock", TYPES.GHOST: "Ghost", TYPES.DRAGON: "Dragon",
		TYPES.DARK: "Dark", TYPES.STEEL: "Steel", TYPES.FAIRY: "Fairy"
	}
	
	for attacking_type in types:
		print("\n" + type_names[attacking_type] + " attacking:")
		for defending_type in types:
			var multiplier = get_type_effectiveness(attacking_type, defending_type)
			if multiplier != 1.0:
				var effectiveness = ""
				if multiplier > 1.0:
					effectiveness = "SUPER EFFECTIVE"
				else:
					effectiveness = "NOT VERY EFFECTIVE"
				print("  vs " + type_names[defending_type] + ": " + str(multiplier) + "x (" + effectiveness + ")")
	
	print("\n=== TEST COMPLETE ===")

func get_effectiveness_description(multiplier: float) -> String:
	"""Get a description of the effectiveness based on multiplier."""
	if multiplier >= 1.25:
		return "super effective"
	elif multiplier <= 0.8:
		return "not very effective"
	else:
		return "normal effectiveness"

# Global sprite sheet manager instance
var sprite_manager: SpriteSheetManager
var pokemon_loader: DynamicPokemonLoader

func _ready():
	# Initialize the sprite sheet manager
	sprite_manager = SpriteSheetManager.new()
	add_child(sprite_manager)
	
	# Initialize the dynamic Pokemon loader
	pokemon_loader = DynamicPokemonLoader.new()
	add_child(pokemon_loader)

class Move:
	var name: String
	var damage: int
	var accuracy: int
	var type: TYPES

	func _init(name: String, damage: int, accuracy: int, type: TYPES) -> void:
		self.name = name
		self.damage = damage
		self.accuracy = accuracy
		self.type = type

class PokemonTexture:
	var front: Texture
	var back: Texture
	var front_shiny: Texture
	var back_shiny: Texture
	
	func _init(sprite_manager: SpriteSheetManager, pokemon_id: int) -> void:
		# Get sprites from sprite sheet manager
		self.front = sprite_manager.get_normal_front_sprite(pokemon_id)
		self.back = sprite_manager.get_normal_back_sprite(pokemon_id)
		self.front_shiny = sprite_manager.get_shiny_front_sprite(pokemon_id)
		self.back_shiny = sprite_manager.get_shiny_back_sprite(pokemon_id)

class Pokemon:
	var id: int
	var name: String
	var type: TYPES
	var hp: int
	var attack: int
	var defense: int
	var speed: int
	var moves: Array[Move]
	var texture: PokemonTexture

	func _init(id: int, name: String, type: TYPES, hp: int, attack: int, defense: int, speed: int, moves: Array[Move], sprite_manager: SpriteSheetManager) -> void:
		self.id = id
		self.name = name
		self.type = type
		self.hp = hp
		self.attack = attack
		self.defense = defense
		self.speed = speed
		self.moves = moves
		self.texture = PokemonTexture.new(sprite_manager, id)

func get_pokemon(id: int) -> Pokemon:
	"""Get a Pokemon by ID using the dynamic loader."""
	if pokemon_loader:
		return pokemon_loader.get_pokemon(id)
	return null

func get_all_pokemon() -> Dictionary:
	"""Get all Pokemon using the dynamic loader."""
	if pokemon_loader:
		return pokemon_loader.get_all_pokemon()
	return {}

var POKEMON_COUNT = 251
