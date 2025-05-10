extends Node

@onready var options_canvas: CanvasLayer = $CanvasLayer

@export var tab_container: TabContainer

var menu_state_to_return := SceneTransition.menu_state.PAUSE_MENU

func _ready() -> void:
	options_canvas.visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("cancel"):
		if SceneTransition.current_menu_state == SceneTransition.menu_state.OPTIONS:
			close_options()

func _on_back_pressed() -> void:
	close_options()
	
func close_options():
	SceneTransition.current_menu_state = menu_state_to_return
	$CanvasLayer.visible = false
	match menu_state_to_return:
		SceneTransition.menu_state.START_MENU:
			get_tree().current_scene.reset_focus()
		SceneTransition.menu_state.PAUSE_MENU:
			PauseMenu.pause_menu_canvas.visible = true
			PauseMenu.reset_focus()
	
func reset_focus():
	tab_container.get_tab_bar().grab_focus()
