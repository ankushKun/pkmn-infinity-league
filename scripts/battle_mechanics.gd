extends Node
class_name BattleMechanics

# Status effect types
enum STATUS_EFFECTS {
	NONE,
	POISON,
	BURN,
	PARALYSIS,
	SLEEP,
	FREEZE,
	CONFUSION
}

# Weather types
enum WEATHER {
	CLEAR,
	RAIN,
	SUN,
	SANDSTORM,
	HAIL
}

# Status effect data structure
class StatusEffect:
	var type: STATUS_EFFECTS
	var duration: int
	var intensity: float
	
	func _init(effect_type: STATUS_EFFECTS, dur: int = -1, intens: float = 1.0):
		type = effect_type
		duration = dur # -1 means permanent until cured
		intensity = intens

# Battle state
var current_weather: WEATHER = WEATHER.CLEAR
var weather_duration: int = 0

# Status effect messages
const STATUS_MESSAGES = {
	STATUS_EFFECTS.POISON: "was poisoned!",
	STATUS_EFFECTS.BURN: "was burned!",
	STATUS_EFFECTS.PARALYSIS: "was paralyzed!",
	STATUS_EFFECTS.SLEEP: "fell asleep!",
	STATUS_EFFECTS.FREEZE: "was frozen solid!",
	STATUS_EFFECTS.CONFUSION: "became confused!"
}

# Weather effect messages
const WEATHER_MESSAGES = {
	WEATHER.RAIN: "It started to rain!",
	WEATHER.SUN: "The sunlight became harsh!",
	WEATHER.SANDSTORM: "A sandstorm kicked up!",
	WEATHER.HAIL: "It started to hail!"
}

func calculate_weather_damage(pokemon_type: PokemonData.TYPES) -> int:
	"""Calculate weather damage for Pokemon types."""
	match current_weather:
		WEATHER.SANDSTORM:
			if pokemon_type in [PokemonData.TYPES.ROCK, PokemonData.TYPES.GROUND, PokemonData.TYPES.STEEL]:
				return 0 # Immune to sandstorm damage
			else:
				return 6 # 6% max HP damage
		WEATHER.HAIL:
			if pokemon_type == PokemonData.TYPES.ICE:
				return 0 # Immune to hail damage
			else:
				return 6 # 6% max HP damage
		_:
			return 0

func apply_weather_effects(pokemon: PokemonData.Pokemon, current_hp: int) -> int:
	"""Apply weather effects and return new HP."""
	var weather_damage = calculate_weather_damage(pokemon.type)
	if weather_damage > 0:
		var damage = int(pokemon.hp * weather_damage / 100.0)
		return max(0, current_hp - damage)
	return current_hp

func calculate_status_damage(status: StatusEffect, pokemon: PokemonData.Pokemon, current_hp: int) -> int:
	"""Calculate status effect damage."""
	match status.type:
		STATUS_EFFECTS.POISON:
			var damage = int(pokemon.hp * 0.125) # 12.5% max HP
			return max(0, current_hp - damage)
		STATUS_EFFECTS.BURN:
			var damage = int(pokemon.hp * 0.0625) # 6.25% max HP
			return max(0, current_hp - damage)
		_:
			return current_hp

func can_move_with_status(status: StatusEffect) -> bool:
	"""Check if Pokemon can move with current status."""
	match status.type:
		STATUS_EFFECTS.SLEEP:
			return false
		STATUS_EFFECTS.FREEZE:
			return false
		STATUS_EFFECTS.PARALYSIS:
			# 25% chance to be fully paralyzed
			return randf() > 0.25
		STATUS_EFFECTS.CONFUSION:
			# 33% chance to hurt itself
			return randf() > 0.33
		STATUS_EFFECTS.NONE:
			return true
		_:
			return true

func get_status_damage_multiplier(status: StatusEffect) -> float:
	"""Get attack damage multiplier from status effects."""
	match status.type:
		STATUS_EFFECTS.BURN:
			return 0.5 # Burn reduces physical attack by 50%
		_:
			return 1.0

func get_weather_damage_multiplier(move_type: PokemonData.TYPES) -> float:
	"""Get damage multiplier from weather effects."""
	match current_weather:
		WEATHER.SUN:
			if move_type == PokemonData.TYPES.FIRE:
				return 1.5 # Fire moves boosted in sun
			elif move_type == PokemonData.TYPES.WATER:
				return 0.5 # Water moves weakened in sun
			else:
				return 1.0
		WEATHER.RAIN:
			if move_type == PokemonData.TYPES.WATER:
				return 1.5 # Water moves boosted in rain
			elif move_type == PokemonData.TYPES.FIRE:
				return 0.5 # Fire moves weakened in rain
			else:
				return 1.0
		_:
			return 1.0

func get_smart_enemy_move(enemy_pokemon: PokemonData.Pokemon, player_pokemon: PokemonData.Pokemon, enemy_moves: Array[PokemonData.Move]) -> PokemonData.Move:
	"""AI to choose the best move for the enemy."""
	var best_move = enemy_moves[0]
	var best_score = 0.0
	
	for move in enemy_moves:
		var score = calculate_move_score(move, enemy_pokemon, player_pokemon)
		if score > best_score:
			best_score = score
			best_move = move
	
	# Add some randomness to make it less predictable
	if randf() < 0.2: # 20% chance to pick random move
		return enemy_moves[randi() % enemy_moves.size()]
	
	return best_move

func calculate_move_score(move: PokemonData.Move, attacker: PokemonData.Pokemon, defender: PokemonData.Pokemon) -> float:
	"""Calculate how good a move is against the defender."""
	var score = 0.0
	
	# Base score from move power
	score += move.damage * 0.1
	
	# Type effectiveness bonus
	var type_multiplier = 1.0
	if PokemonData.TypeIsStrongAgainst(move.type, defender.type):
		type_multiplier = 2.0
		score += 50 # Big bonus for super effective moves
	elif PokemonData.TypeIsWeakAgainst(move.type, defender.type):
		type_multiplier = 0.5
		score -= 20 # Penalty for not very effective moves
	
	# STAB bonus
	if move.type == attacker.type:
		score += 10
	
	# Accuracy consideration
	score += move.accuracy * 0.1
	
	# Weather bonus
	var weather_bonus = get_weather_damage_multiplier(move.type)
	if weather_bonus > 1.0:
		score += 15
	elif weather_bonus < 1.0:
		score -= 10
	
	return score

func get_status_effect_chance(move: PokemonData.Move) -> float:
	"""Get chance of inflicting status effects (simplified)."""
	# This is a simplified system - in real Pokemon, each move has specific status chances
	var status_moves = {
		"Thunder Wave": 0.9,
		"Will-O-Wisp": 0.85,
		"Toxic": 0.9,
		"Sleep Powder": 0.75,
		"Confuse Ray": 1.0
	}
	
	return status_moves.get(move.name, 0.0)

func can_inflict_status(status: STATUS_EFFECTS, target_type: PokemonData.TYPES) -> bool:
	"""Check if status can be inflicted on target type."""
	match status:
		STATUS_EFFECTS.POISON:
			return target_type != PokemonData.TYPES.STEEL
		STATUS_EFFECTS.BURN:
			return target_type != PokemonData.TYPES.FIRE
		STATUS_EFFECTS.PARALYSIS:
			return target_type != PokemonData.TYPES.ELECTRIC
		STATUS_EFFECTS.SLEEP:
			return true
		STATUS_EFFECTS.FREEZE:
			return target_type != PokemonData.TYPES.ICE
		STATUS_EFFECTS.CONFUSION:
			return true
		_:
			return true

func get_critical_hit_chance(move: PokemonData.Move) -> float:
	"""Get critical hit chance for a move."""
	# Simplified critical hit system
	var base_chance = 0.0625 # 6.25% base chance
	
	# Some moves have higher critical hit ratios
	var high_crit_moves = ["Slash", "Razor Leaf", "Crabhammer", "Karate Chop"]
	if move.name in high_crit_moves:
		base_chance = 0.125 # 12.5% chance
	
	return base_chance

func calculate_evasion_and_accuracy(attacker_accuracy: int, defender_evasion: int = 100) -> float:
	"""Calculate final accuracy considering evasion."""
	var final_accuracy = float(attacker_accuracy) / float(defender_evasion) * 100.0
	return clamp(final_accuracy, 0.0, 100.0)