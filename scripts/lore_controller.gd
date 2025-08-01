extends Control

@onready var bg_panel: Panel = $Bg
@onready var lore_text: RichTextLabel = $LoreText
@onready var continue_button: Button = $Button

var fade_duration: float = 60
var text_speed: float = 0.058
var current_line: int = 0
var lines: PackedStringArray = []
var fade_timer: float = 0.0
var text_timer: float = 0.0
var is_fading: bool = true
var is_typing: bool = true
var current_text: String = ""

# Skip functionality
var enter_press_time: float = 0.0
var double_press_threshold: float = 0.5
var original_text: String = ""

func _ready() -> void:
	# Initialize
	continue_button.visible = false
	
	# Get the original text and split into lines
	original_text = lore_text.text

	lore_text.text = ""
	
	var temp_lines = original_text.split("\n")
	lines = PackedStringArray()
	for line in temp_lines:
		if line.strip_edges() != "":
			lines.append(line)

func _process(delta: float) -> void:
	# Handle skip functionality
	_handle_skip_input(delta)
	
	if is_fading:
		_handle_fade(delta)
	
	if is_typing:
		_handle_text_animation(delta)
	
	# Check if everything is complete
	if not is_fading and not is_typing:
		continue_button.visible = true

func _handle_skip_input(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"): # Enter key
		var current_time = Time.get_ticks_msec() / 1000.0 # Convert to seconds
		if current_time - enter_press_time < double_press_threshold:
			# Double press detected - skip everything
			_skip_animation()
		enter_press_time = current_time

func _skip_animation() -> void:
	# Skip to the end immediately
	is_fading = false
	is_typing = false
	bg_panel.modulate = Color(0.1, 0.1, 0.1, 1.0) # Final fade state
	lore_text.text = original_text # Show all text
	continue_button.visible = true

func _handle_fade(delta: float) -> void:
	fade_timer += delta
	var progress = fade_timer / fade_duration
	
	if progress >= 1.0:
		# Keep 10% visibility instead of pure black
		bg_panel.modulate = Color(0.1, 0.1, 0.1, 1.0)
		is_fading = false
	else:
		# Fade from original color to 10% visibility
		var original_color = Color(0.3, 0.3, 0.3, 1.0)
		var target_color = Color(0.1, 0.1, 0.1, 1.0) # 10% visibility
		bg_panel.modulate = original_color.lerp(target_color, progress)

func _handle_text_animation(delta: float) -> void:
	text_timer += delta
	
	if text_timer >= text_speed:
		text_timer = 0.0
		
		if current_line < lines.size():
			# Build complete text up to current line
			var complete_text = ""
			for i in range(current_line):
				complete_text += lines[i] + "\n\n"
			
			# Add current line with partial characters
			var current_line_text = lines[current_line]
			var current_chars = current_text.length() - complete_text.length()
			
			if current_chars < current_line_text.length():
				# Add one more character to current line
				complete_text += current_line_text.substr(0, current_chars + 1)
			else:
				# Current line is complete, move to next
				complete_text += current_line_text
				current_line += 1
				if current_line < lines.size():
					complete_text += "\n\n"
			
			current_text = complete_text
		
		# Update the displayed text
		lore_text.text = current_text
		
		# Scroll to bottom to show the latest text
		# lore_text.scroll_to_line(lore_text.get_line_count() - 1)
		
		# Check if we're done with all lines
		if current_line >= lines.size():
			is_typing = false


func _on_button_button_up() -> void:
	# start menu screen
	get_tree().change_scene_to_file("res://screens/main.tscn")
