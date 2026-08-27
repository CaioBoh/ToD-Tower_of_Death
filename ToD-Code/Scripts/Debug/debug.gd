extends Node

@export var debug_canvas: CanvasLayer
@export var debug_properties_container: VBoxContainer
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

func _ready() -> void:
	debug_canvas.visible = false
	for property in debug_properties_container.get_children():
		debug_properties.push_back(property as PanelContainer)

func _input(event: InputEvent) -> void:
	if OS.is_debug_build() and event.is_action_pressed("Debug Mode") and not SceneTransition.isTransitioning:
		if debug_menu_active:
			close_debug_menu()
		else:
			open_debug_menu()

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
	debug_menu_active = value

func toggle_enemy_detection() -> void:
	enemy_detection = not enemy_detection
	get_tree().call_group("Enemy Detection", "_debug_toggle_player_detection")


func toggle_take_damage() -> void:
	take_damage = not take_damage
