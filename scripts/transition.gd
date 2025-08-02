extends Control

@onready var swipe = $Swipe

@onready var swipe_from_right = $Swipe/Right
@onready var swipe_from_left = $Swipe/Left

func _ready():
	# Make sure the swipe panel is visible
	swipe.visible = true
	Transition.visible = true

	# Initialize panel positions
	_initialize_panel_positions()

func _initialize_panel_positions():
	var viewport_size = get_viewport().get_visible_rect().size
	# Position panels off-screen initially
	swipe_from_left.position = Vector2(-viewport_size.x, 0)
	swipe_from_right.position = Vector2(viewport_size.x, 0)
	# Set proper size for panels
	swipe_from_left.size = Vector2(viewport_size.x, viewport_size.y)
	swipe_from_right.size = Vector2(viewport_size.x, viewport_size.y)
	# Make sure panels are visible
	swipe_from_left.visible = true
	swipe_from_right.visible = true

# animation is of 2 types:
# 1. swipe: bars slide in from left and right of the screen
# to cover up the active scene, when scene gets covered,
# the other scene is loaded, and the bars slide back out
# 2. boxes: TODO
func change_scene(path: String, animation: String):
	match animation:
		"swipe":
			swipe.visible = true
			await slide_in()
			get_tree().change_scene_to_file(path)
			await get_tree().create_timer(0.5).timeout
			await slide_out()
			swipe.visible = false
		"boxes":
			animate_boxes()
		_:
			pass
	

func slide_in():
	print("slide_in")
	var tween = create_tween()
	tween.parallel().tween_property(swipe_from_left, "position:x", 0, 1)
	tween.parallel().tween_property(swipe_from_right, "position:x", 0, 1)
	await tween.finished
	print("slide_in finished")

func slide_out():
	print("slide_out")
	var tween = create_tween()
	tween.parallel().tween_property(swipe_from_left, "position:x", -get_viewport().get_visible_rect().size.x, 1)
	tween.parallel().tween_property(swipe_from_right, "position:x", get_viewport().get_visible_rect().size.x, 1)
	await tween.finished
	print("slide_out finished")

func animate_boxes():
	pass
