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
	STEEL
}

const TYPE_EFFECTIVENESS = {
		TYPES.NORMAL: {"weak": [TYPES.ROCK, TYPES.STEEL], "strong": []},
		TYPES.FIRE: {"weak": [TYPES.FIRE, TYPES.WATER, TYPES.ROCK, TYPES.DRAGON], "strong": [TYPES.GRASS, TYPES.ICE, TYPES.BUG, TYPES.STEEL]},
		TYPES.WATER: {"weak": [TYPES.WATER, TYPES.GRASS, TYPES.DRAGON], "strong": [TYPES.FIRE, TYPES.GROUND, TYPES.ROCK]},
		TYPES.ELECTRIC: {"weak": [TYPES.ELECTRIC, TYPES.GRASS, TYPES.DRAGON], "strong": [TYPES.WATER, TYPES.FLYING]},
		TYPES.GRASS: {"weak": [TYPES.FIRE, TYPES.GRASS, TYPES.POISON, TYPES.FLYING, TYPES.BUG, TYPES.DRAGON, TYPES.STEEL], "strong": [TYPES.WATER, TYPES.GROUND, TYPES.ROCK]},
		TYPES.ICE: {"weak": [TYPES.FIRE, TYPES.WATER, TYPES.ICE, TYPES.STEEL], "strong": [TYPES.GRASS, TYPES.GROUND, TYPES.FLYING, TYPES.DRAGON]},
		TYPES.FIGHTING: {"weak": [TYPES.POISON, TYPES.FLYING, TYPES.PSYCHIC, TYPES.BUG], "strong": [TYPES.NORMAL, TYPES.ICE, TYPES.ROCK, TYPES.DARK, TYPES.STEEL]},
		TYPES.POISON: {"weak": [TYPES.POISON, TYPES.GROUND, TYPES.ROCK, TYPES.GHOST], "strong": [TYPES.GRASS]},
		TYPES.GROUND: {"weak": [TYPES.GRASS, TYPES.BUG], "strong": [TYPES.FIRE, TYPES.ELECTRIC, TYPES.POISON, TYPES.ROCK, TYPES.STEEL]},
		TYPES.FLYING: {"weak": [TYPES.ELECTRIC, TYPES.ROCK, TYPES.STEEL], "strong": [TYPES.GRASS, TYPES.FIGHTING, TYPES.BUG]},
		TYPES.PSYCHIC: {"weak": [TYPES.PSYCHIC, TYPES.STEEL], "strong": [TYPES.FIGHTING, TYPES.POISON]},
		TYPES.BUG: {"weak": [TYPES.FIRE, TYPES.FIGHTING, TYPES.POISON, TYPES.FLYING, TYPES.GHOST, TYPES.STEEL], "strong": [TYPES.GRASS, TYPES.PSYCHIC, TYPES.DARK]},
		TYPES.ROCK: {"weak": [TYPES.FIGHTING, TYPES.GROUND, TYPES.STEEL], "strong": [TYPES.FIRE, TYPES.ICE, TYPES.FLYING, TYPES.BUG]},
		TYPES.GHOST: {"weak": [TYPES.DARK], "strong": [TYPES.PSYCHIC, TYPES.GHOST]},
		TYPES.DRAGON: {"weak": [TYPES.STEEL], "strong": [TYPES.DRAGON]},
		TYPES.DARK: {"weak": [TYPES.FIGHTING, TYPES.DARK], "strong": [TYPES.PSYCHIC, TYPES.GHOST]},
		TYPES.STEEL: {"weak": [TYPES.FIRE, TYPES.WATER, TYPES.ELECTRIC, TYPES.STEEL], "strong": [TYPES.ICE, TYPES.ROCK]}
	}
	
func TypeIsWeakAgainst(typeA: TYPES, typeB: TYPES) -> bool:
	# Returns true if typeA is weak against typeB
	return typeB in TYPE_EFFECTIVENESS.get(typeA, {}).get("weak", [])

func TypeIsStrongAgainst(typeA: TYPES, typeB: TYPES) -> bool:
	# Returns true if typeA is strong against typeB
	return typeB in TYPE_EFFECTIVENESS.get(typeA, {}).get("strong", [])

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
