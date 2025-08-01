extends Node

var selected_starter
var tween: Tween

var chikorita_container: Control
var cyndaquil_container: Control
var totodile_container: Control

var chikorita_button: TextureButton
var cyndaquil_button: TextureButton
var totodile_button: TextureButton

var random_pokemon: TextureRect
var initial_pokemon_position: Vector2

enum STARTERS {
	Chikorita = 152,
	Cyndaquil = 155,
	Totodile = 158
}

func _ready() -> void:
	$StarterPreview.visible = false
	$StarterName.visible = false
	$StartButton.visible = false
	
	chikorita_container = $ChikoritaContainer
	cyndaquil_container = $CyndaquilContainer
	totodile_container = $TotodileContainer
	
	chikorita_button = $ChikoritaContainer/Chikorita
	cyndaquil_button = $CyndaquilContainer/Cyndaquil
	totodile_button = $TotodileContainer/Totodile

	random_pokemon = $RandomPokemon
	initial_pokemon_position = random_pokemon.position
	
	# Start the random Pokemon animation loop
	start_random_pokemon_loop()

func start_random_pokemon_loop():
	# Set initial position off-screen to the right
	random_pokemon.position.x = get_viewport().get_visible_rect().size.x + 100
	
	# Start the animation sequence
	animate_random_pokemon()

func animate_random_pokemon():
	# Select a random Pokemon
	var random_id = randi() % PokemonData.POKEMON_COUNT + 1
	var pokemon = PokemonData.get_pokemon(random_id)
	random_pokemon.texture = pokemon.texture.front
	
	# Get screen dimensions
	var screen_width = get_viewport().get_visible_rect().size.x
	
	# Create new tween for this animation cycle
	tween = create_tween()
	tween.set_parallel(false)
	
	# 1. Move from right to initial position (1 second)
	tween.tween_property(random_pokemon, "position", initial_pokemon_position, 1.0)
	
	# 2. Stay at initial position for 3 seconds
	tween.tween_interval(3.0)
	
	# 3. Move back to right and disappear (1 second)
	tween.tween_property(random_pokemon, "position:x", screen_width + 100, 1.0)
	
	# 4. When animation completes, start the next cycle
	tween.tween_callback(animate_random_pokemon)

		
func _on_chikorita_pressed() -> void:
	selected_starter = STARTERS.Chikorita
	on_select()


func _on_cyndaquil_pressed() -> void:
	selected_starter = STARTERS.Cyndaquil
	on_select()


func _on_totodile_pressed() -> void:
	selected_starter = STARTERS.Totodile
	on_select()


func on_select():
	$StarterPreview.visible = true
	$StarterName.visible = true
	$StartButton.visible = true
	var pokemon = PokemonData.get_pokemon(selected_starter)
	$StarterPreview.texture = pokemon.texture.front
	$StarterName.text = pokemon.name
	
	chikorita_button.disabled = false
	cyndaquil_button.disabled = false
	totodile_button.disabled = false
	
	var container: Control
	match selected_starter:
		STARTERS.Chikorita:
			container = chikorita_container
			chikorita_button.disabled = true
		STARTERS.Cyndaquil:
			container = cyndaquil_container
			cyndaquil_button.disabled = true
		STARTERS.Totodile:
			container = totodile_container
			totodile_button.disabled = true

	# Animate the selected Pokéball
	animate_pokeball(container)


func animate_pokeball(container: Control):	
	# Store original position and rotation
	var original_position = container.position
	var original_rotation = container.rotation
	
	# Create a new Tween for this animation
	tween = create_tween()
	tween.set_parallel(true)
	
	# First bounce - up and rotate
	tween.tween_property(container, "position", original_position + Vector2(0, -30), 0.15)
	tween.tween_property(container, "rotation", deg_to_rad(15), 0.15)
	tween.tween_property(container, "scale", Vector2(1.1, 1.1), 0.15)
	
	# Second bounce - down and rotate back
	tween.tween_property(container, "position", original_position + Vector2(0, -10), 0.1).set_delay(0.15)
	tween.tween_property(container, "rotation", deg_to_rad(-10), 0.1).set_delay(0.15)
	
	# Final settle - back to original position
	tween.tween_property(container, "position", original_position, 0.1).set_delay(0.25)
	tween.tween_property(container, "rotation", original_rotation, 0.1).set_delay(0.25)
	tween.tween_property(container, "scale", Vector2(1.0, 1.0), 0.1).set_delay(0.25)
	
	tween.play()


func _on_start_button_clicked() -> void:
	if selected_starter in [STARTERS.Chikorita, STARTERS.Cyndaquil, STARTERS.Totodile]:
		print(selected_starter)
		Global.starter_pokemon_id = selected_starter
		get_tree().change_scene_to_file("res://screens/battle.tscn")
	else:
		print("illegal starter")
