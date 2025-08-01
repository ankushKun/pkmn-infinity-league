extends Node
class_name SpriteSheetManager

# Sprite sheet textures
var normal_front_sheet: Texture2D
var normal_back_sheet: Texture2D
var shiny_front_sheet: Texture2D
var shiny_back_sheet: Texture2D

# Metadata for sprite positions
var normal_front_metadata: Dictionary
var normal_back_metadata: Dictionary
var shiny_front_metadata: Dictionary
var shiny_back_metadata: Dictionary

# Sprite size (96x96 for Pokemon sprites)
var sprite_size: int = 96

func _ready():
	load_sprite_sheets()

func load_sprite_sheets():
	"""Load all sprite sheets and metadata."""
	# Load normal front sprites
	var normal_front_sheet_path = "res://sprites/pokemon_normal_front_sheet.png"
	var normal_front_metadata_path = "res://sprites/pokemon_normal_front_sheet_metadata.json"
	
	if FileAccess.file_exists(normal_front_sheet_path):
		normal_front_sheet = load(normal_front_sheet_path)
		print("Loaded normal front sprite sheet")
	
	if FileAccess.file_exists(normal_front_metadata_path):
		var file = FileAccess.open(normal_front_metadata_path, FileAccess.READ)
		var json_string = file.get_as_text()
		normal_front_metadata = JSON.parse_string(json_string)
		file.close()
		print("Loaded normal front metadata")
	
	# Load normal back sprites
	var normal_back_sheet_path = "res://sprites/pokemon_normal_back_sheet.png"
	var normal_back_metadata_path = "res://sprites/pokemon_normal_back_sheet_metadata.json"
	
	if FileAccess.file_exists(normal_back_sheet_path):
		normal_back_sheet = load(normal_back_sheet_path)
		print("Loaded normal back sprite sheet")
	
	if FileAccess.file_exists(normal_back_metadata_path):
		var file = FileAccess.open(normal_back_metadata_path, FileAccess.READ)
		var json_string = file.get_as_text()
		normal_back_metadata = JSON.parse_string(json_string)
		file.close()
		print("Loaded normal back metadata")
	
	# Load shiny front sprites
	var shiny_front_sheet_path = "res://sprites/pokemon_shiny_front_sheet.png"
	var shiny_front_metadata_path = "res://sprites/pokemon_shiny_front_sheet_metadata.json"
	
	if FileAccess.file_exists(shiny_front_sheet_path):
		shiny_front_sheet = load(shiny_front_sheet_path)
		print("Loaded shiny front sprite sheet")
	
	if FileAccess.file_exists(shiny_front_metadata_path):
		var file = FileAccess.open(shiny_front_metadata_path, FileAccess.READ)
		var json_string = file.get_as_text()
		shiny_front_metadata = JSON.parse_string(json_string)
		file.close()
		print("Loaded shiny front metadata")
	
	# Load shiny back sprites
	var shiny_back_sheet_path = "res://sprites/pokemon_shiny_back_sheet.png"
	var shiny_back_metadata_path = "res://sprites/pokemon_shiny_back_sheet_metadata.json"
	
	if FileAccess.file_exists(shiny_back_sheet_path):
		shiny_back_sheet = load(shiny_back_sheet_path)
		print("Loaded shiny back sprite sheet")
	
	if FileAccess.file_exists(shiny_back_metadata_path):
		var file = FileAccess.open(shiny_back_metadata_path, FileAccess.READ)
		var json_string = file.get_as_text()
		shiny_back_metadata = JSON.parse_string(json_string)
		file.close()
		print("Loaded shiny back metadata")

func get_sprite_texture(pokemon_id: int, is_front: bool = true, is_shiny: bool = false) -> Texture2D:
	"""Get a sprite texture from the appropriate sprite sheet."""
	var metadata: Dictionary
	var sheet: Texture2D
	
	if is_shiny:
		metadata = shiny_front_metadata if is_front else shiny_back_metadata
		sheet = shiny_front_sheet if is_front else shiny_back_sheet
	else:
		metadata = normal_front_metadata if is_front else normal_back_metadata
		sheet = normal_front_sheet if is_front else normal_back_sheet
	
	if not metadata.has("sprites") or not metadata["sprites"].has(str(pokemon_id)):
		print("Pokemon ID ", pokemon_id, " not found in ", "shiny " if is_shiny else "normal ", "front" if is_front else "back", " sprites")
		return null
	
	var sprite_data = metadata["sprites"][str(pokemon_id)]
	var rect = Rect2(sprite_data["x"], sprite_data["y"], sprite_data["width"], sprite_data["height"])
	
	# Create a new texture from the sprite sheet region
	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = sheet
	atlas_texture.region = rect
	
	return atlas_texture

func get_sprite_region(pokemon_id: int, is_front: bool = true, is_shiny: bool = false) -> Rect2:
	"""Get the region coordinates for a sprite."""
	var metadata: Dictionary
	
	if is_shiny:
		metadata = shiny_front_metadata if is_front else shiny_back_metadata
	else:
		metadata = normal_front_metadata if is_front else normal_back_metadata
	
	if not metadata.has("sprites") or not metadata["sprites"].has(str(pokemon_id)):
		print("Pokemon ID ", pokemon_id, " not found in ", "shiny " if is_shiny else "normal ", "front" if is_front else "back", " sprites")
		return Rect2()
	
	var sprite_data = metadata["sprites"][str(pokemon_id)]
	return Rect2(sprite_data["x"], sprite_data["y"], sprite_data["width"], sprite_data["height"])

func set_sprite_on_node(node: Node2D, pokemon_id: int, is_front: bool = true, is_shiny: bool = false):
	"""Set a sprite on a node (Sprite2D, AnimatedSprite2D, etc.)."""
	var texture = get_sprite_texture(pokemon_id, is_front, is_shiny)
	if not texture:
		return
		
	if node is Sprite2D:
		node.texture = texture
	elif node is AnimatedSprite2D:
		node.sprite_frames = SpriteFrames.new()
		node.sprite_frames.add_animation("default")
		node.sprite_frames.add_frame("default", texture)
		node.play("default")

func get_available_pokemon_ids(is_front: bool = true, is_shiny: bool = false) -> Array:
	"""Get a list of available Pokemon IDs for the specified type."""
	var metadata: Dictionary
	
	if is_shiny:
		metadata = shiny_front_metadata if is_front else shiny_back_metadata
	else:
		metadata = normal_front_metadata if is_front else normal_back_metadata
	
	if not metadata.has("sprites"):
		return []
	
	# Convert string keys to integers
	var ids = []
	for key in metadata["sprites"].keys():
		ids.append(int(key))
	
	return ids

func get_total_sprite_count(is_front: bool = true, is_shiny: bool = false) -> int:
	"""Get the total number of sprites in a sheet."""
	var metadata: Dictionary
	
	if is_shiny:
		metadata = shiny_front_metadata if is_front else shiny_back_metadata
	else:
		metadata = normal_front_metadata if is_front else normal_back_metadata
	
	if not metadata.has("total_sprites"):
		return 0
	
	return metadata["total_sprites"]

# Convenience functions for common use cases
func get_normal_front_sprite(pokemon_id: int) -> Texture2D:
	return get_sprite_texture(pokemon_id, true, false)

func get_normal_back_sprite(pokemon_id: int) -> Texture2D:
	return get_sprite_texture(pokemon_id, false, false)

func get_shiny_front_sprite(pokemon_id: int) -> Texture2D:
	return get_sprite_texture(pokemon_id, true, true)

func get_shiny_back_sprite(pokemon_id: int) -> Texture2D:
	return get_sprite_texture(pokemon_id, false, true)
