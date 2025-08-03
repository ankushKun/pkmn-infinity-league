extends Node

@onready var IntroTransitionGrid: GridContainer = $IntroTransition
@onready var PokedexContainer: Panel = $Pokedex
@onready var PokemonGrid: GridContainer = $Pokedex/ScrollContainer/GridContainer

var ActivePokemonHP: int = 0
var EnemyPokemonHP: int = 0

var ActivePokemon: PokemonData.Pokemon
var EnemyPokemon: PokemonData.Pokemon

# Store original positions
@onready var player_original_position = $Player.position
@onready var enemy_original_position = $Enemy.position

var active_moves: Array[PokemonData.Move] = []
var enemy_moves: Array[PokemonData.Move] = []

var ColorGreen = Color(0.0, 1.0, 0.0, 1.0)
var ColorYellow = Color(1.0, 1.0, 0.0, 1.0)
var ColorRed = Color(1.0, 0.0, 0.0, 1.0)

var attack_sounds = [
	preload("res://sounds/attacks/1.mp3"),
	preload("res://sounds/attacks/2.mp3"),
	preload("res://sounds/attacks/3.mp3"),
]

var move_buttons: Array[Button] = []

# Battle state
var is_player_turn: bool = true
var battle_ended: bool = false

# Random number generator for consistent results
var rng: RandomNumberGenerator

# Status effects for both Pokemon
var player_status_effect: String = "NONE"
var enemy_status_effect: String = "NONE"

func _ready() -> void:
	$Result.visible = false
	rng = RandomNumberGenerator.new()
	rng.seed = Time.get_unix_time_from_system()
	populate_pokedex()
	_on_close_button_down()
	
	move_buttons = [
		$"Menu/Moves/1",
		$"Menu/Moves/2",
		$"Menu/Moves/3",
		$"Menu/Moves/4",
	]

	if Global.starter_pokemon_id:
		# Add starter Pokemon to encountered list
		Global.add_encountered_pokemon(Global.starter_pokemon_id)
		set_active_pokemon(Global.starter_pokemon_id)
	else:
		var random_id = rng.randi() % 252 + 1
		Global.add_encountered_pokemon(random_id)
		set_active_pokemon(random_id)

	play_entrance_animation(false)
		
	# Start with circular panel visibility animation
	await animate_panels_circular()

	# Start entrance animation
	await play_entrance_animation(true)
	await get_tree().create_timer(0.5).timeout

	update_progress_text()
	
	set_status("What will you do?")

func populate_pokedex():
	$Pokedex/Counter.text = "" + str(Global.defeated_pokemon_count) + " / 251"

	var all_pokemon = PokemonData.get_all_pokemon()
	var default = PokemonGrid.get_child(0).duplicate()
	
	var children = PokemonGrid.get_children()
	for child in children:
		PokemonGrid.remove_child(child)
		child.queue_free()
	
	for pokemon_id in all_pokemon:
		var pokemon: PokemonData.Pokemon = all_pokemon[pokemon_id]
		var template = default.duplicate()
		var texture = template.get_child(0)
		texture.texture = pokemon.texture.front
#		If we have not encountered this pokemon before, set texture to black and white
		if Global.has_defeated_pokemon(pokemon_id):
			texture.material = null
		var label = template.get_child(1)
		label.text = pokemon.name
		PokemonGrid.add_child(template)
	PokemonGrid.remove_child(default)

func animate_panels_circular() -> void:
	"""Animate panels in a wave pattern from top-left to bottom-right, setting visibility to false."""
	
	IntroTransitionGrid.visible = true
	# Create the specific order based on the visual pattern
	# The pattern appears to be a wave that starts from top-left and moves diagonally
	var panel_order = [39, 40, 51, 50, 49, 38, 27, 28, 29, 30, 41, 52, 63, 62, 61, 60, 59, 48, 37, 26, 15, 16, 17, 18, 19, 20, 31, 42, 53, 64, 75, 74, 73, 72, 71, 70, 69, 58, 47, 36, 25, 14, 3, 4, 5, 6, 7, 8, 9, 10, 21, 32, 43, 54, 65, 76, 68, 57, 46, 35, 24, 13, 2, 11, 22, 33, 44, 55, 66, 77, 67, 56, 45, 34, 23, 12, 1]

	
	# Animate panels in the specific order
	for panel_index in panel_order:
		var panel = IntroTransitionGrid.get_child(panel_index - 1)
		
		if panel:
			# panel.visible = false
			var style = StyleBoxFlat.new()
			style.set("bg_color", Color(0, 0, 0, 0))
			panel.set("theme_override_styles/panel", style)
			
			# Small delay between each panel for smooth animation
			await get_tree().create_timer(0.025).timeout # 25ms delay
	IntroTransitionGrid.visible = false

func play_entrance_animation(full: bool) -> void:
	"""Play entrance animation where player and enemy move in from the sides."""
	
	# Set initial positions (off-screen)
	$Player.position = player_original_position + Vector2(-500, 0) # Start from left
	$Enemy.position = enemy_original_position + Vector2(500, 0) # Start from right

	if not full:
		return
	
	# Create tween for smooth movement
	var entrance_tween = create_tween()
	entrance_tween.set_parallel(true)
	
	# Move player from left to original position (5 seconds)
	entrance_tween.tween_property($Player, "position", player_original_position, 2)
	
	# Move enemy from right to original position (5 seconds)
	entrance_tween.tween_property($Enemy, "position", enemy_original_position, 2)
	
	# Wait for animation to complete
	await entrance_tween.finished

func play_random_attack_sound():
	var sound = attack_sounds[rng.randi() % attack_sounds.size()]
	$Attack.stream = sound
	$Attack.pitch_scale = rng.randf_range(0.8, 1.2)
	$Attack.volume_db = rng.randf_range(-5, 5)
	$Attack.play()

func play_low_hp_sound(start: bool):
	if start:
		if not $LowHP.playing:
			$LowHP.play()
	else:
		$LowHP.stop()

func play_faint_sound():
	$Faint.play()

func play_heal_sound():
	if not $Heal.playing:
		$Heal.play()

func check_low_hp_sound():
	"""Check if low HP sound should be played or stopped based on current HP."""
	var player_hp_percent = float(ActivePokemonHP) / float(ActivePokemon.hp)
	
	# Play low HP sound when player HP is below 25%
	if player_hp_percent <= 0.25 and ActivePokemonHP > 0:
		play_low_hp_sound(true)
	else:
		play_low_hp_sound(false)


func _process(delta: float) -> void:
	pass

func get_4_random_moves(moves: Array[PokemonData.Move]) -> Array[PokemonData.Move]:
	var selected_moves: Array[PokemonData.Move] = []
	var available_moves = moves.duplicate()
	
	# Select up to 4 unique moves
	for i in range(min(4, available_moves.size())):
		if available_moves.is_empty():
			break
		
		# Pick a random move from available moves
		var idx = rng.randi() % available_moves.size()
		var random_move = available_moves[idx]
		
		if random_move != null:
			selected_moves.append(random_move)
		
		# Remove the selected move from available moves to prevent duplicates
		available_moves.remove_at(idx)
	
	return selected_moves

func random_enemy_move():
	"""Get a smart enemy move based on type effectiveness and move power."""
	var best_move = enemy_moves[0]
	var best_score = 0.0
	var move_scores = []
	
	# Calculate scores for all moves
	for move in enemy_moves:
		var score = calculate_move_score(move, EnemyPokemon, ActivePokemon)
		move_scores.append({"move": move, "score": score})
		if score > best_score:
			best_score = score
			best_move = move
	
	# Sort moves by score
	move_scores.sort_custom(func(a, b): return a.score > b.score)
	
	# Add strategic randomness based on move quality
	var random_chance = 0.3 # 30% chance to pick non-optimal move
	if rng.randf() < random_chance and move_scores.size() > 1:
		# Pick from top 2 moves with weighted probability
		var top_moves = move_scores.slice(0, min(2, move_scores.size()))
		var total_score = 0.0
		for move_data in top_moves:
			total_score += move_data.score
		
		var random_val = rng.randf() * total_score
		var current_sum = 0.0
		for move_data in top_moves:
			current_sum += move_data.score
			if random_val <= current_sum:
				return move_data.move
	
	return best_move

func calculate_move_score(move: PokemonData.Move, attacker: PokemonData.Pokemon, defender: PokemonData.Pokemon) -> float:
	"""Calculate how good a move is against the defender with improved scoring."""
	var score = 0.0
	
	# Base score from move power (normalized)
	# Most moves are 40-80 power, so normalize around that range
	var normalized_power = float(move.damage) / 80.0
	score += normalized_power * 20
	
	# Type effectiveness bonus
	if PokemonData.TypeIsStrongAgainst(move.type, defender.type):
		score += 50 # Big bonus for super effective moves
	elif PokemonData.TypeIsWeakAgainst(move.type, defender.type):
		score -= 20 # Penalty for not very effective moves
	
	# STAB bonus
	if move.type == attacker.type:
		score += 15
	
	# Accuracy consideration (higher accuracy = better score)
	score += move.accuracy * 0.2
	
	# Consider defender's HP for move selection
	# Prefer high-power moves against high-HP Pokemon
	if defender.hp > 100:
		score += normalized_power * 10 # Bonus for high-power moves vs tanks
	elif defender.hp < 50:
		score += (1.0 - normalized_power) * 5 # Slight preference for lower power vs frail Pokemon
	
	# Prefer moves that won't overkill
	var estimated_damage = move.damage * 0.8 # Rough estimate
	if estimated_damage > defender.hp * 0.8:
		score -= 10 # Penalty for moves that might overkill
	
	return score

var is_displaying_status = false

func update_progress_text():
	"""Update the progress text to show number of defeated Pokémon."""
	$Progress.text = str(Global.defeated_pokemon_count)

func set_status(status: String):
	"""Display status text character by character."""
	# Wait for any existing status display to finish
	while is_displaying_status:
		await get_tree().create_timer(0.01).timeout
	
	is_displaying_status = true
	
	# Clear the text first
	$Menu/Status.text = ""
	
	# Build the text character by character
	for i in range(status.length()):
		$Menu/Status.text += status[i]
		await get_tree().create_timer(0.03).timeout # 50ms delay between characters
	
	is_displaying_status = false

func set_active_pokemon(id: int):
	ActivePokemon = PokemonData.get_pokemon(id)
	
	# Get a unique enemy Pokemon based on player's Pokemon strength
	var player_strength = Global.calculate_pokemon_strength(ActivePokemon)
	var strength_based_enemy_id = Global.get_strength_based_pokemon_id(player_strength)
	EnemyPokemon = PokemonData.get_pokemon(strength_based_enemy_id)
	
	# Add the enemy to encountered list
	Global.add_encountered_pokemon(strength_based_enemy_id)
	
	ActivePokemonHP = ActivePokemon.hp
	EnemyPokemonHP = EnemyPokemon.hp
	
	$Player.texture = ActivePokemon.texture.back
	$Enemy.texture = EnemyPokemon.texture.front
	
	$PlayerInfo/hpbar.max_value = ActivePokemon.hp
	$PlayerInfo/hpbar.value = ActivePokemonHP
	
	$EnemyInfo/hpbar.max_value = EnemyPokemon.hp
	$EnemyInfo/hpbar.value = EnemyPokemonHP
	
	$PlayerInfo/name.text = ActivePokemon.name
	$EnemyInfo/name.text = EnemyPokemon.name
	
	update_hp_display()

	# Player
	active_moves = get_4_random_moves(ActivePokemon.moves.duplicate())
	
	# set the move buttons to the selected moves, clear text if not enough moves
	for i in range(4):
		if i < active_moves.size():
			move_buttons[i].text = active_moves[i].name
		else:
			move_buttons[i].text = ""
	
	# Enemy
	enemy_moves = get_4_random_moves(EnemyPokemon.moves.duplicate())

func update_hp_display():
	$PlayerInfo/hp.text = str(ActivePokemonHP) + " / " + str(ActivePokemon.hp)
	# enemy doesnot have hp text
	
	# Update HP bar values (this was missing!)
	$PlayerInfo/hpbar.value = ActivePokemonHP
	$EnemyInfo/hpbar.value = EnemyPokemonHP
	
	# Update HP bar fill colors based on percentage
	var player_hp_percent = float(ActivePokemonHP) / float(ActivePokemon.hp)
	var enemy_hp_percent = float(EnemyPokemonHP) / float(EnemyPokemon.hp)
	
	# Set player HP bar fill color
	if player_hp_percent > 0.5:
		$PlayerInfo/hpbar.get("theme_override_styles/fill").bg_color = ColorGreen
	elif player_hp_percent > 0.25:
		$PlayerInfo/hpbar.get("theme_override_styles/fill").bg_color = ColorYellow
	else:
		$PlayerInfo/hpbar.get("theme_override_styles/fill").bg_color = ColorRed
	
	# Set enemy HP bar fill color
	if enemy_hp_percent > 0.5:
		$EnemyInfo/hpbar.get("theme_override_styles/fill").bg_color = ColorGreen
	elif enemy_hp_percent > 0.25:
		$EnemyInfo/hpbar.get("theme_override_styles/fill").bg_color = ColorYellow
	else:
		$EnemyInfo/hpbar.get("theme_override_styles/fill").bg_color = ColorRed
	
	# Check for low HP sound
	check_low_hp_sound()

func animate_hp_bar(bar: ProgressBar, target_value: int, duration: float = 0.5):
	"""Animate HP bar smoothly from current value to target value."""
	var start_value = bar.value
	var tween = create_tween()
	tween.tween_property(bar, "value", target_value, duration)
	await tween.finished

func set_enabled(enable: bool):
	for button in move_buttons:
		button.disabled = !enable

# Battle Mechanics Functions

func calculate_type_effectiveness(attack_type: PokemonData.TYPES, defender_type: PokemonData.TYPES) -> float:
	"""Calculate type effectiveness multiplier using the comprehensive chart."""
	return PokemonData.get_type_effectiveness(attack_type, defender_type)

func calculate_damage(attacker: PokemonData.Pokemon, defender: PokemonData.Pokemon, move: PokemonData.Move) -> Dictionary:
	"""Calculate damage using an improved Pokemon damage formula for balanced battles."""
	if move.damage == 0:
		return {"damage": 0, "is_critical": false, "type_multiplier": 1.0}
	
	# Base damage calculation with improved scaling
	var level = 50 # Assume level 50 for simplicity
	var attack_stat = attacker.attack
	var defense_stat = defender.defense
	
	# Critical hit check (6.25% chance)
	var is_critical = rng.randf() < 0.0625
	if is_critical:
		attack_stat = int(attack_stat * 1.5)
	
	# STAB (Same Type Attack Bonus)
	var stab_multiplier = 1.0
	if move.type == attacker.type:
		stab_multiplier = 1.5
	
	# Type effectiveness
	var type_multiplier = calculate_type_effectiveness(move.type, defender.type)
	
	# Status effect modifiers
	var status_multiplier = 1.0
	if player_status_effect == "BURN":
		status_multiplier = 0.5 # Burn reduces physical attack
	
	# Improved damage scaling based on Pokemon stats
	# This creates more balanced battles by considering the defender's HP
	var base_damage = move.damage
	var stat_ratio = float(attack_stat) / float(defense_stat)
	
	# Scale damage based on the defender's HP to prevent one-shot kills
	var hp_scaling = 1.0
	var defender_hp_percent = float(defender.hp) / 100.0 # Normalize HP to percentage
	
	# For low HP Pokemon, reduce damage to prevent instant KO
	if defender.hp <= 50:
		hp_scaling = 0.6 # 60% damage for low HP Pokemon
	elif defender.hp <= 80:
		hp_scaling = 0.8 # 80% damage for medium HP Pokemon
	# High HP Pokemon (100+) get full damage
	
	# Calculate final damage with improved formula
	var damage = int(((2 * level / 5 + 2) * base_damage * stat_ratio / 50 + 2) *
					stab_multiplier * type_multiplier * status_multiplier * hp_scaling)
	
	# Random factor (0.85 to 1.0)
	var random_factor = 0.85 + (rng.randf() * 0.15)
	damage = int(damage * random_factor)
	
	# Ensure damage doesn't exceed 90% of defender's max HP (prevents one-shot kills)
	var max_damage = int(defender.hp * 0.9)
	damage = min(damage, max_damage)
	
	# Ensure minimum damage of 1
	return {
		"damage": max(1, damage),
		"is_critical": is_critical,
		"type_multiplier": type_multiplier
	}

func check_accuracy(move: PokemonData.Move) -> bool:
	"""Check if a move hits based on accuracy."""
	var accuracy_roll = rng.randf() * 100
	return accuracy_roll <= move.accuracy

func apply_damage(target_hp: int, damage: int) -> int:
	"""Apply damage and return new HP."""
	return max(0, target_hp - damage)

func show_move_effectiveness_info(move: PokemonData.Move, defender_type: PokemonData.TYPES):
	"""Show type effectiveness information for a move."""
	var multiplier = PokemonData.get_type_effectiveness(move.type, defender_type)
	
	var effectiveness_msg = ""
	if multiplier > 1.0:
		effectiveness_msg = "It's super effective!"
	elif multiplier < 1.0:
		effectiveness_msg = "It's not very effective..."
	# Don't show anything for normal effectiveness (multiplier == 1.0)
	
	if effectiveness_msg != "":
		await set_status(effectiveness_msg)
		await get_tree().create_timer(1.0).timeout

func get_move_effectiveness_hint(move: PokemonData.Move, defender_type: PokemonData.TYPES) -> String:
	"""Get a hint about move effectiveness for strategic play."""
	var multiplier = PokemonData.get_type_effectiveness(move.type, defender_type)
	
	if multiplier > 1.0:
		return "This move is super effective!"
	elif multiplier < 1.0:
		return "This move is not very effective..."
	else:
		return "" # Don't show anything for normal effectiveness

func get_detailed_effectiveness_info(move_type: PokemonData.TYPES, defender_type: PokemonData.TYPES) -> String:
	"""Get detailed type effectiveness information for display."""
	var multiplier = PokemonData.get_type_effectiveness(move_type, defender_type)
	
	var info = ""
	if multiplier > 1.0:
		info = "Super effective"
	elif multiplier < 1.0:
		info = "Not very effective"
	# Don't show anything for normal effectiveness (multiplier == 1.0)
	
	return info

func get_effectiveness_message(move_type: PokemonData.TYPES, defender_type: PokemonData.TYPES) -> String:
	"""Get the effectiveness message for display using the new type system."""
	var multiplier = PokemonData.get_type_effectiveness(move_type, defender_type)
	var description = PokemonData.get_effectiveness_description(multiplier)
	
	if multiplier > 1.0:
		return "It's " + description + "!"
	elif multiplier < 1.0:
		return "It's " + description + "..."
	else:
		return ""

func get_type_name(type_enum: PokemonData.TYPES) -> String:
	"""Convert type enum to string name."""
	var type_names = {
		PokemonData.TYPES.NORMAL: "Normal",
		PokemonData.TYPES.FIRE: "Fire",
		PokemonData.TYPES.WATER: "Water",
		PokemonData.TYPES.ELECTRIC: "Electric",
		PokemonData.TYPES.GRASS: "Grass",
		PokemonData.TYPES.ICE: "Ice",
		PokemonData.TYPES.FIGHTING: "Fighting",
		PokemonData.TYPES.POISON: "Poison",
		PokemonData.TYPES.GROUND: "Ground",
		PokemonData.TYPES.FLYING: "Flying",
		PokemonData.TYPES.PSYCHIC: "Psychic",
		PokemonData.TYPES.BUG: "Bug",
		PokemonData.TYPES.ROCK: "Rock",
		PokemonData.TYPES.GHOST: "Ghost",
		PokemonData.TYPES.DRAGON: "Dragon",
		PokemonData.TYPES.DARK: "Dark",
		PokemonData.TYPES.STEEL: "Steel",
		PokemonData.TYPES.FAIRY: "Fairy"
	}
	return type_names.get(type_enum, "Normal")

func apply_random_status_effect(target: PokemonData.Pokemon, is_player: bool):
	"""Apply a random status effect to the target."""
	var status_effects = ["POISON", "BURN", "PARALYSIS"]
	var random_effect = status_effects[rng.randi() % status_effects.size()]
	
	# Check if the target is immune to the status effect
	var is_immune = false
	match random_effect:
		"POISON":
			is_immune = (target.type == PokemonData.TYPES.STEEL or target.type == PokemonData.TYPES.FAIRY)
		"BURN":
			is_immune = (target.type == PokemonData.TYPES.FIRE)
		"PARALYSIS":
			is_immune = (target.type == PokemonData.TYPES.ELECTRIC)
	
	if is_immune:
		return
	
	# Apply the status effect
	if is_player:
		enemy_status_effect = random_effect
		await set_status("Enemy " + target.name + " was " + random_effect.to_lower() + "ed!")
	else:
		player_status_effect = random_effect
		await set_status(target.name + " was " + random_effect.to_lower() + "ed!")
	
	await get_tree().create_timer(1.0).timeout

func capture_enemy_pokemon():
	"""Capture the defeated enemy Pokemon and make it the player's active Pokemon."""
	# Increment defeated Pokémon count
	Global.increment_defeated_pokemon()
	update_progress_text()
	
	await set_status("You defeated " + EnemyPokemon.name + "!")
	await get_tree().create_timer(1.5).timeout
	
	# Store original positions for animation
	var player_original_position = $Player.position
	var enemy_original_position = $Enemy.position
	
	# Animation: Enemy moves to player position
	# set_status("Capturing " + EnemyPokemon.name + "...")
	var capture_tween = create_tween()
	capture_tween.tween_property($Enemy, "position", player_original_position, 0.8)
	capture_tween.tween_callback(switch_pokemon_textures)
	capture_tween.tween_callback(hide_enemy)
	capture_tween.tween_property($Enemy, "position", enemy_original_position, 0.8)
	capture_tween.tween_callback(show_enemy)
	await capture_tween.finished
	
	# Get a new unique enemy based on player's Pokemon strength
	var player_strength = Global.calculate_pokemon_strength(ActivePokemon)
	var strength_based_enemy_id = Global.get_strength_based_pokemon_id(player_strength)
	EnemyPokemon = PokemonData.get_pokemon(strength_based_enemy_id)
	Global.add_encountered_pokemon(strength_based_enemy_id)
	
	# Update sprites for new enemy
	$Enemy.texture = EnemyPokemon.texture.front
	
	# Refill both Pokemon HP to full
	ActivePokemonHP = ActivePokemon.hp
	EnemyPokemonHP = EnemyPokemon.hp
	
	# Update HP bars to full with animation
	$PlayerInfo/hpbar.max_value = ActivePokemon.hp
	$EnemyInfo/hpbar.max_value = EnemyPokemon.hp
	
	play_heal_sound()
	# Animate both HP bars to full
	await animate_hp_bar($PlayerInfo/hpbar, ActivePokemonHP)
	await animate_hp_bar($EnemyInfo/hpbar, EnemyPokemonHP)
	
	# Update names
	$PlayerInfo/name.text = ActivePokemon.name
	$EnemyInfo/name.text = EnemyPokemon.name
	
	# Update moves for both Pokemon
	active_moves = get_4_random_moves(ActivePokemon.moves.duplicate())
	enemy_moves = get_4_random_moves(EnemyPokemon.moves.duplicate())
	
	# Update move buttons
	for i in range(4):
		if i < active_moves.size():
			move_buttons[i].text = active_moves[i].name
		else:
			move_buttons[i].text = ""
	
	update_hp_display()
	
	await set_status("A new " + EnemyPokemon.name + " appeared!")
	await get_tree().create_timer(1.5).timeout
	
	# Re-enable move buttons and wait for user input
	set_enabled(true)
	await set_status("What will you do?")

func switch_pokemon_textures():
	"""Switch the Pokemon textures during capture animation."""
	# The defeated enemy becomes the player's active Pokemon
	ActivePokemon = EnemyPokemon
	
	# Update player sprite to the captured Pokemon
	$Player.texture = ActivePokemon.texture.back

func hide_enemy():
	"""Hide the enemy sprite during animation."""
	$Enemy.visible = false

func show_enemy():
	"""Show the enemy sprite after animation."""
	$Enemy.visible = true

func play_faint_animation():
	"""Play a faint animation when the player's Pokemon faints."""
	# Stop low HP sound when Pokemon faints
	play_low_hp_sound(false)

	# Play a faint sound
	play_faint_sound()
	
	# Store original properties
	var original_position = $Player.position
	var original_scale = $Player.scale
	
	# Create faint animation tween
	var faint_tween = create_tween()
	
	# Shrink the Pokemon and move towards bottom left
	faint_tween.parallel().tween_property($Player, "scale", Vector2(0.1, 0.1), 0.4)
	faint_tween.parallel().tween_property($Player, "position", original_position + Vector2(0, 1000), 0.8)
	
	await faint_tween.finished
	
	# Hide the Pokemon
	$Player.visible = false
	
	# Reset scale and position for next battle
	$Player.scale = original_scale
	$Player.position = original_position

func apply_status_damage():
	"""Apply damage from status effects at the end of turn."""
	# Apply poison damage
	if player_status_effect == "POISON":
		var poison_damage = int(ActivePokemon.hp * 0.125) # 12.5% max HP
		var new_hp = max(0, ActivePokemonHP - poison_damage)
		ActivePokemonHP = new_hp
		await set_status(ActivePokemon.name + " was hurt by poison!")
		await animate_hp_bar($PlayerInfo/hpbar, new_hp)
		update_hp_display()
		await get_tree().create_timer(1.0).timeout
	
	# Apply burn damage
	if player_status_effect == "BURN":
		var burn_damage = int(ActivePokemon.hp * 0.0625) # 6.25% max HP
		var new_hp = max(0, ActivePokemonHP - burn_damage)
		ActivePokemonHP = new_hp
		await set_status(ActivePokemon.name + " was hurt by its burn!")
		await animate_hp_bar($PlayerInfo/hpbar, new_hp)
		update_hp_display()
		await get_tree().create_timer(1.0).timeout
	
	# Check if player fainted from status
	if ActivePokemonHP <= 0:
		ActivePokemonHP = 0
		update_hp_display()
		await set_status(ActivePokemon.name + " fainted from status!")
		battle_ended = true
		await play_faint_animation()
		await get_tree().create_timer(2.0).timeout
		end_battle()

func execute_move(attacker: PokemonData.Pokemon, defender: PokemonData.Pokemon, move: PokemonData.Move, is_player: bool) -> bool:
	"""Execute a move and return true if the move was successful."""
	var attacker_name = attacker.name if is_player else "Enemy " + attacker.name
	var defender_name = defender.name if not is_player else "Enemy " + defender.name
	
	# Check status effects that prevent movement
	if not is_player and player_status_effect == "SLEEP":
		await set_status(attacker_name + " is fast asleep!")
		await get_tree().create_timer(1.5).timeout
		return false
	elif not is_player and player_status_effect == "PARALYSIS":
		if rng.randf() < 0.25: # 25% chance to be fully paralyzed
			await set_status(attacker_name + " is paralyzed and can't move!")
			await get_tree().create_timer(1.5).timeout
			return false
	
	# Check accuracy
	if not check_accuracy(move):
		await set_status(attacker_name + " used " + move.name + " but it missed!")
		await get_tree().create_timer(1.5).timeout
		return false
	
	# Play attack sound
	play_random_attack_sound()
	
	# Calculate damage
	var damage_result = calculate_damage(attacker, defender, move)
	var damage = damage_result.damage
	var is_critical = damage_result.is_critical
	var type_multiplier = damage_result.type_multiplier
	
	# Apply damage
	var new_hp = 0
	if is_player:
		new_hp = apply_damage(EnemyPokemonHP, damage)
		EnemyPokemonHP = new_hp
		# Animate enemy HP bar
		await animate_hp_bar($EnemyInfo/hpbar, new_hp)
	else:
		new_hp = apply_damage(ActivePokemonHP, damage)
		ActivePokemonHP = new_hp
		# Animate player HP bar
		await animate_hp_bar($PlayerInfo/hpbar, new_hp)
	
	# Update display (text and colors)
	update_hp_display()
	
	# Display move message
	var move_message = attacker_name + " used " + move.name + "!"
	await set_status(move_message)
	await get_tree().create_timer(1.0).timeout
	
	# Display effectiveness message
	var effectiveness_msg = get_effectiveness_message(move.type, defender.type)
	if effectiveness_msg != "":
		await set_status(effectiveness_msg)
		await get_tree().create_timer(1.0).timeout
	
	# Display damage message with additional info
	if damage > 0:
		var damage_message = "It dealt " + str(damage) + " damage!"
		
		# Add effectiveness info without multiplier values
		if type_multiplier > 1.0:
			damage_message += " (Super effective!)"
		elif type_multiplier < 1.0:
			damage_message += " (Not very effective...)"
		
		# Add critical hit info
		if is_critical:
			damage_message += " (Critical hit!)"
		
		await set_status(damage_message)
		await get_tree().create_timer(1.5).timeout
	
	# Check for status effect application
	if damage > 0 and rng.randf() < 0.1: # 10% chance for status effect
		apply_random_status_effect(defender, is_player)
	
	# Check if defender fainted
	var defender_fainted = false
	if is_player and EnemyPokemonHP <= 0:
		EnemyPokemonHP = 0
		update_hp_display()
		await set_status("Enemy " + defender.name + " fainted!")
		defender_fainted = true
		# Capture the enemy Pokemon
		capture_enemy_pokemon()
		# Return early to prevent further turn execution
		return true
	elif not is_player and ActivePokemonHP <= 0:
		ActivePokemonHP = 0
		update_hp_display()
		await set_status(defender.name + " fainted!")
		defender_fainted = true
		battle_ended = true
		# Play faint animation
		await play_faint_animation()
	
	if defender_fainted:
		await get_tree().create_timer(2.0).timeout
		if battle_ended:
			end_battle()
	
	return true

func end_battle():
	"""End the battle and return to main menu."""
	# Stop low HP sound when battle ends
	play_low_hp_sound(false)
	
	if ActivePokemonHP <= 0:
		await set_status("You lost the battle!")
	else:
		await set_status("You won the battle!")
	
	await get_tree().create_timer(3.0).timeout
	show_defeat_popup()

# Move execution functions
func use_move_1():
	if battle_ended or ActivePokemonHP <= 0:
		return
	
	set_enabled(false)
	play_player_attack_animation()
	
	# Execute player move
	var move_result = await execute_move(ActivePokemon, EnemyPokemon, active_moves[0], true)
	
	# If enemy was defeated, return early to prevent further turn execution
	if move_result and EnemyPokemonHP <= 0:
		return
	
	if not battle_ended:
		# Execute enemy move
		var enemy_move = random_enemy_move()
		play_enemy_attack_animation()
		await execute_move(EnemyPokemon, ActivePokemon, enemy_move, false)
	
	# Apply status damage at end of turn
	if not battle_ended:
		await apply_status_damage()
		# Re-enable buttons for next turn
		set_enabled(true)
		await set_status("What will you do?")

func use_move_2():
	if battle_ended or ActivePokemonHP <= 0:
		return
	
	set_enabled(false)
	play_player_attack_animation()
	
	# Execute player move
	var move_result = await execute_move(ActivePokemon, EnemyPokemon, active_moves[1], true)
	
	# If enemy was defeated, return early to prevent further turn execution
	if move_result and EnemyPokemonHP <= 0:
		return
	
	if not battle_ended:
		# Execute enemy move
		var enemy_move = random_enemy_move()
		play_enemy_attack_animation()
		await execute_move(EnemyPokemon, ActivePokemon, enemy_move, false)
	
	# Apply status damage at end of turn
	if not battle_ended:
		await apply_status_damage()
		# Re-enable buttons for next turn
		set_enabled(true)
		await set_status("What will you do?")

func use_move_3():
	if battle_ended or ActivePokemonHP <= 0:
		return
	
	set_enabled(false)
	play_player_attack_animation()
	
	# Execute player move
	var move_result = await execute_move(ActivePokemon, EnemyPokemon, active_moves[2], true)
	
	# If enemy was defeated, return early to prevent further turn execution
	if move_result and EnemyPokemonHP <= 0:
		return
	
	if not battle_ended:
		# Execute enemy move
		var enemy_move = random_enemy_move()
		play_enemy_attack_animation()
		await execute_move(EnemyPokemon, ActivePokemon, enemy_move, false)
	
	# Apply status damage at end of turn
	if not battle_ended:
		await apply_status_damage()
		# Re-enable buttons for next turn
		set_enabled(true)
		await set_status("What will you do?")

func use_move_4():
	if battle_ended or ActivePokemonHP <= 0:
		return
	
	set_enabled(false)
	play_player_attack_animation()
	
	# Execute player move
	var move_result = await execute_move(ActivePokemon, EnemyPokemon, active_moves[3], true)
	
	# If enemy was defeated, return early to prevent further turn execution
	if move_result and EnemyPokemonHP <= 0:
		return
	
	if not battle_ended:
		# Execute enemy move
		var enemy_move = random_enemy_move()
		play_enemy_attack_animation()
		await execute_move(EnemyPokemon, ActivePokemon, enemy_move, false)
	
	# Apply status damage at end of turn
	if not battle_ended:
		await apply_status_damage()
		# Re-enable buttons for next turn
		set_enabled(true)
		await set_status("What will you do?")

func play_player_attack_animation():
	# Store original position
	var original_position = $Player.position
	
	# Move player forward (attack animation)
	var tween = create_tween()
	tween.tween_property($Player, "position", original_position + Vector2(50, 0), 0.2)
	tween.tween_property($Player, "position", original_position, 0.2)
	
	# Optional: Add a flash effect to the enemy
	var enemy_original_modulate = $Enemy.modulate
	$Enemy.modulate = Color.WHITE
	await get_tree().create_timer(0.1).timeout
	$Enemy.modulate = enemy_original_modulate

func play_enemy_attack_animation():
	# Store original position
	var original_position = $Enemy.position
	
	# Move enemy forward (attack animation)
	var tween = create_tween()
	tween.tween_property($Enemy, "position", original_position + Vector2(-50, 0), 0.2)
	tween.tween_property($Enemy, "position", original_position, 0.2)
	
	# Optional: Add a flash effect to the player
	var player_original_modulate = $Player.modulate
	$Player.modulate = Color.WHITE
	await get_tree().create_timer(0.1).timeout
	$Player.modulate = player_original_modulate

func show_defeat_popup():
	$Result.visible = true
	$Result/Label.text = "You lost to [color=red]" + EnemyPokemon.name + "[/color]!\nBeat [color=yellow]" + str(Global.defeated_pokemon_count) + "[/color] / 251 Pokemon"
	# Reset defeated pokemon counter and encountered pokemons array after showing the defeat popup
	Global.reset_on_defeat()

func _on_restart_pressed() -> void:
	# get_tree().change_scene_to_file("res://screens/main.tscn")
	Transition.change_scene("res://screens/main.tscn", "swipe")


func _on_close_button_down() -> void:
	$Pokedex.visible = false


func _on_pokedex_button_down() -> void:
	$Pokedex.visible = true
	populate_pokedex()
