extends Node

@export var debug_canvas: CanvasLayer
@export var debug_properties_container: VBoxContainer
@export var debug_teleport_canvas: CanvasLayer
@onready var teleport_option_button_scene: PackedScene = preload("res://Scenes/Debug/Teleport Option.tscn")

var debug_properties: Array[PanelContainer]
var auto_skip_dialogues: bool = false
var enemy_detection: bool = true
var take_damage: bool = true
var take_knockback: bool = true
var no_clip: bool = false  
var drag_enemies: bool = false

var previous_focused_control: Control = null
var previous_menu_state: SceneTransition.menu_state
var debug_menu_active: bool = false
var teleport_menu_active: bool = false

func _ready() -> void:
	debug_canvas.visible = false
	for property in debug_properties_container.get_children():
		debug_properties.push_back(property as PanelContainer)

func _input(event: InputEvent) -> void:
	if not (OS.is_debug_build() and (SceneTransition.current_menu_state == SceneTransition.menu_state.PLAYING\
	or SceneTransition.current_menu_state == SceneTransition.menu_state.DEBUG_MENU)):
		return
	if event.is_action_pressed("Debug Mode") and not SceneTransition.isTransitioning:
		if debug_menu_active:
			if teleport_menu_active:
				close_teleport_menu()
			else:
				close_debug_menu()
		else:
			open_debug_menu()
			
	if not debug_menu_active:
		return
		
	if event.is_action_pressed("cancel"):
		if teleport_menu_active:
			close_teleport_menu()
		else:
			close_debug_menu()

func open_debug_menu():
	toggle_debug_menu(true)
	previous_focused_control = get_viewport().gui_get_focus_owner()
	previous_menu_state = SceneTransition.current_menu_state
	SceneTransition.current_menu_state = SceneTransition.menu_state.DEBUG_MENU
	
func close_debug_menu():
	toggle_debug_menu(false)
	if is_instance_valid(previous_focused_control):
		previous_focused_control.grab_focus()
		previous_focused_control = null
	SceneTransition.current_menu_state = previous_menu_state 
		
func toggle_debug_menu(value: bool):
	debug_canvas.visible = value
	get_tree().paused = value
	set_deferred("debug_menu_active", value)

func toggle_enemy_detection() -> void:
	enemy_detection = not enemy_detection
	get_tree().call_group("Enemy Detection", "_debug_toggle_player_detection")

func toggle_take_damage() -> void:
	take_damage = not take_damage

func toggle_take_knockback() -> void:
	take_knockback = not take_knockback
	
func toggle_no_clip() -> void:
	Global.global_player.set_collision_mask_value(2, no_clip)
	no_clip = not no_clip

func open_teleport_menu() -> void:
	var debug_node: Node = get_tree().current_scene.get_node("Debug")
	if not is_instance_valid(debug_node):
		return
	var teleport_locations: Node = debug_node.get_node("Teleport Locations")
	if not is_instance_valid(teleport_locations):
		return
	
	teleport_menu_active = true
	debug_canvas.visible = false
	debug_teleport_canvas.visible = true
	
	var teleport_options_container: VBoxContainer = debug_teleport_canvas.get_node("CenterContainer").\
	get_node("ScrollContainer").get_node("VBoxContainer")
	var teleport_option_button: Button
	
	for old_teleport_location in teleport_options_container.get_children():
		old_teleport_location.queue_free()
	
	for teleport_location: Marker2D in teleport_locations.get_children():
		teleport_option_button = teleport_option_button_scene.instantiate() as Button
		teleport_options_container.add_child(teleport_option_button)
		
		teleport_option_button.text = teleport_location.name
		teleport_option_button.pressed.connect(
			func():
				Global.global_player.global_position = teleport_location.global_position
				close_teleport_menu()
				close_debug_menu()
		)
	
func close_teleport_menu():
	teleport_menu_active = false
	debug_canvas.visible = true
	debug_teleport_canvas.visible = false
	
