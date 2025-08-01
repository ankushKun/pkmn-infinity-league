extends "res://scripts/pokemon_data.gd"
class_name DynamicPokemonLoader

# Type mapping from JSON to Godot enum
const TYPE_MAPPING = {
	"Normal": TYPES.NORMAL,
	"Fire": TYPES.FIRE,
	"Water": TYPES.WATER,
	"Electric": TYPES.ELECTRIC,
	"Grass": TYPES.GRASS,
	"Ice": TYPES.ICE,
	"Fighting": TYPES.FIGHTING,
	"Poison": TYPES.POISON,
	"Ground": TYPES.GROUND,
	"Flying": TYPES.FLYING,
	"Psychic": TYPES.PSYCHIC,
	"Bug": TYPES.BUG,
	"Rock": TYPES.ROCK,
	"Ghost": TYPES.GHOST,
	"Dragon": TYPES.DRAGON,
	"Dark": TYPES.DARK,
	"Steel": TYPES.STEEL
}

# Compatible move types for each Pokemon type
const COMPATIBLE_TYPES = {
	"Normal": ["Fighting", "Flying", "Ground", "Rock", "Steel"],
	"Fire": ["Fighting", "Ground", "Rock", "Steel"],
	"Water": ["Ground", "Rock", "Steel"],
	"Electric": ["Flying", "Ground", "Rock", "Steel"],
	"Grass": ["Fighting", "Ground", "Rock"],
	"Ice": ["Flying", "Ground", "Rock", "Steel"],
	"Fighting": ["Normal", "Rock", "Steel", "Ice", "Dark"],
	"Poison": ["Grass", "Fairy"],
	"Ground": ["Fire", "Electric", "Poison", "Rock", "Steel"],
	"Flying": ["Grass", "Fighting", "Bug"],
	"Psychic": ["Fighting", "Poison"],
	"Bug": ["Grass", "Psychic", "Dark"],
	"Rock": ["Fire", "Ice", "Flying", "Bug"],
	"Ghost": ["Psychic", "Ghost"],
	"Dragon": ["Dragon"],
	"Dark": ["Psychic", "Ghost"],
	"Steel": ["Ice", "Rock"]
}

var pokedex_data: Array
var moves_data: Array
var moves_by_type: Dictionary
var pokemon_cache: Dictionary = {}

func _ready():
	# Initialize sprite manager
	sprite_manager = SpriteSheetManager.new()
	add_child(sprite_manager)
	
	# Load JSON data
	load_json_data()
	
	# Group moves by type
	group_moves_by_type()
	
	# Generate Pokemon dictionary once
	generate_pokemon_dictionary()

func load_json_data():
	"""Load Pokemon and moves data from JSON files."""
	var pokedex_file = FileAccess.open("res://data/pokedex.json", FileAccess.READ)
	if pokedex_file:
		var json_string = pokedex_file.get_as_text()
		pokedex_data = JSON.parse_string(json_string)
		pokedex_file.close()
		print("Loaded pokedex data: ", pokedex_data.size(), " Pokemon")
	else:
		print("Failed to load pokedex.json")
		pokedex_data = []
	
	var moves_file = FileAccess.open("res://data/moves.json", FileAccess.READ)
	if moves_file:
		var json_string = moves_file.get_as_text()
		moves_data = JSON.parse_string(json_string)
		moves_file.close()
		print("Loaded moves data: ", moves_data.size(), " moves")
	else:
		print("Failed to load moves.json")
		moves_data = []

func group_moves_by_type():
	"""Group moves by their type."""
	moves_by_type = {}
	for move in moves_data:
		var move_type = move.get("type", "Normal")
		if not moves_by_type.has(move_type):
			moves_by_type[move_type] = []
		moves_by_type[move_type].append(move)
	print("Grouped moves by type: ", moves_by_type.keys().size(), " types")

func is_valid_move(move: Dictionary) -> bool:
	"""Check if a move has valid power and accuracy values."""
	return (move.get("power") != null and
			move.get("accuracy") != null and
			move.get("ename") != null)

func get_pokemon_moves(pokemon_data: Dictionary) -> Array[Move]:
	"""Get 10 moves for a Pokemon: 5 of their own type and 5 compatible moves."""
	var pokemon_moves: Array[Move] = []
	
	# Get the Pokemon's primary type
	var primary_type = pokemon_data["type"][0] if pokemon_data["type"].size() > 0 else "Normal"
	
	# Get moves of the same type
	var type_moves = []
	if moves_by_type.has(primary_type):
		for move in moves_by_type[primary_type]:
			if is_valid_move(move):
				type_moves.append(move)
	
	# Get Normal type moves as fallback
	var normal_moves = []
	if moves_by_type.has("Normal"):
		for move in moves_by_type["Normal"]:
			if is_valid_move(move):
				normal_moves.append(move)
	
	# Get compatible moves
	var compatible_moves = []
	var compatible_type_list = COMPATIBLE_TYPES.get(primary_type, ["Normal"])
	
	for move_type in compatible_type_list:
		if moves_by_type.has(move_type):
			for move in moves_by_type[move_type]:
				if is_valid_move(move):
					compatible_moves.append(move)
					if compatible_moves.size() >= 10: # Limit to avoid too many moves
						break
	
	# If we don't have enough compatible moves, add more Normal moves
	if compatible_moves.size() < 5:
		compatible_moves.append_array(normal_moves.slice(0, 10))
	
	# Select 5 moves of the same type
	var selected_type_moves = []
	if type_moves.size() >= 5:
		selected_type_moves = type_moves.slice(0, 5)
	elif type_moves.size() > 0:
		selected_type_moves = type_moves
		selected_type_moves.append_array(normal_moves.slice(0, 5 - type_moves.size()))
	else:
		selected_type_moves = normal_moves.slice(0, 5)
	
	# Select 5 compatible moves
	var selected_compatible_moves = []
	if compatible_moves.size() >= 5:
		selected_compatible_moves = compatible_moves.slice(0, 5)
	else:
		selected_compatible_moves = normal_moves.slice(0, 5)
	
	# Combine all selected moves
	var all_selected_moves = selected_type_moves + selected_compatible_moves
	
	# Shuffle the moves to randomize their order while keeping types the same
	all_selected_moves.shuffle()
	
	# Create Move objects
	for move in all_selected_moves:
		var move_name = move.get("ename", "Unknown")
		var power = move.get("power", 40)
		var accuracy = move.get("accuracy", 100)
		var move_type = move.get("type", "Normal")
		var godot_type = TYPE_MAPPING.get(move_type, TYPES.NORMAL)
		
		pokemon_moves.append(Move.new(move_name, power, accuracy, godot_type))
	
	return pokemon_moves

func create_pokemon_from_data(pokemon_data: Dictionary) -> Pokemon:
	"""Create a Pokemon instance from JSON data."""
	var pokemon_id = pokemon_data["id"]
	var name = pokemon_data["name"]["english"]
	
	# Get the primary type (first type in the array)
	var primary_type = pokemon_data["type"][0] if pokemon_data["type"].size() > 0 else "Normal"
	var godot_type = TYPE_MAPPING.get(primary_type, TYPES.NORMAL)
	
	# Get base stats
	var base_stats = pokemon_data.get("base", {})
	var hp = base_stats.get("HP", 50)
	var attack = base_stats.get("Attack", 50)
	var defense = base_stats.get("Defense", 50)
	var speed = base_stats.get("Speed", 50)
	
	# Get moves for this Pokemon
	var moves = get_pokemon_moves(pokemon_data)
	
	# Create Pokemon instance
	return Pokemon.new(pokemon_id, name, godot_type, hp, attack, defense, speed, moves, sprite_manager)

func generate_pokemon_dictionary() -> void:
	"""Generate the complete Pokemons dictionary once and cache it."""
	pokemon_cache.clear()
	
	# Limit to first 251 Pokemon (Gen 2)
	var pokemon_count = min(pokedex_data.size(), 251)
	
	for i in range(pokemon_count):
		var pokemon_data = pokedex_data[i]
		var pokemon = create_pokemon_from_data(pokemon_data)
		pokemon_cache[pokemon.id] = pokemon
	
	print("Generated Pokemon dictionary with ", pokemon_cache.size(), " Pokemon")

func get_pokemon(id: int) -> Pokemon:
	"""Get a Pokemon by ID from the cached dictionary."""
	return pokemon_cache.get(id, null)

func get_all_pokemon() -> Dictionary:
	"""Get all Pokemon from the cached dictionary."""
	return pokemon_cache.duplicate()
