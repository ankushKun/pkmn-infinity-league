extends Node

var starter_pokemon_id: int
var defeated_pokemon_count: int = 0

var encountered_pokemons: Array[int] = []

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func add_encountered_pokemon(pokemon_id: int):
	"""Add a Pokemon ID to the encountered list if not already present."""
	if not encountered_pokemons.has(pokemon_id):
		encountered_pokemons.append(pokemon_id)

func get_unique_pokemon_id() -> int:
	"""Get a random Pokemon ID that hasn't been encountered yet."""
	var available_ids = []
	
	# Generate list of available Pokemon IDs (1-251 for Gen 2)
	for i in range(1, 252):
		if not encountered_pokemons.has(i):
			available_ids.append(i)
	
	# If all Pokemon have been encountered, reset the list
	if available_ids.is_empty():
		encountered_pokemons.clear()
		for i in range(1, 252):
			available_ids.append(i)
	
	# Return a random available ID
	var random_index = randi() % available_ids.size()
	return available_ids[random_index]

func get_strength_based_pokemon_id(player_strength: int) -> int:
	"""Get a Pokemon ID that matches the player's Pokemon strength level."""
	var available_ids = []
	var strength_tolerance = 20 # Allow Pokemon within ±20 strength points
	
	# Generate list of available Pokemon IDs (1-251 for Gen 2)
	for i in range(1, 252):
		if not encountered_pokemons.has(i):
			var pokemon = PokemonData.get_pokemon(i)
			if pokemon:
				var enemy_strength = calculate_pokemon_strength(pokemon)
				if abs(enemy_strength - player_strength) <= strength_tolerance:
					available_ids.append(i)
	
	# If no Pokemon in strength range, expand the range
	if available_ids.is_empty():
		for i in range(1, 252):
			if not encountered_pokemons.has(i):
				available_ids.append(i)
	
	# If still no Pokemon available, reset the list
	if available_ids.is_empty():
		encountered_pokemons.clear()
		for i in range(1, 252):
			available_ids.append(i)
	
	# Return a random available ID
	var random_index = randi() % available_ids.size()
	return available_ids[random_index]

func calculate_pokemon_strength(pokemon: PokemonData.Pokemon) -> int:
	"""Calculate a Pokemon's overall strength based on its stats."""
	var total_stats = pokemon.hp + pokemon.attack + pokemon.defense + pokemon.speed
	return total_stats

func increment_defeated_pokemon():
	"""Increment the count of defeated Pokémon."""
	defeated_pokemon_count += 1
