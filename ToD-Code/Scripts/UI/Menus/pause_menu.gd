extends Node

@onready var pause_menu_canvas: CanvasLayer = $CanvasLayer

@export var continueButton: Button
@export var optionsButton: Button
@export var quitButton: Button

func _ready() -> void:
	pause_menu_canvas.visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("cancel"):
		if SceneTransition.current_menu_state == SceneTransition.menu_state.PLAYING:
			pause_game()
		elif SceneTransition.current_menu_state == SceneTransition.menu_state.PAUSE_MENU:
			continue_game()
		
func pause_game():
	reset_focus()
	$CanvasLayer.visible = true
	get_tree().paused = true
	SceneTransition.current_menu_state = SceneTransition.menu_state.PAUSE_MENU
	
func continue_game():
	$CanvasLayer.visible = false
	get_tree().paused = false
	SceneTransition.current_menu_state = SceneTransition.menu_state.PLAYING
	
func _on_continue_pressed() -> void:
	continue_game()
	
func _on_options_pressed() -> void:
	SceneTransition.current_menu_state = SceneTransition.menu_state.OPTIONS
	$CanvasLayer.visible = false
	Options.options_canvas.visible = true
	Options.menu_state_to_return = SceneTransition.menu_state.PAUSE_MENU
	Options.reset_focus()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	$CanvasLayer.visible = false
	if not SceneTransition.isTransitioning:
		SceneTransition.change_scene("res://Scenes/UI/Menus/start_menu.tscn", SceneTransition.menu_state.START_MENU)
		
func reset_focus():
	continueButton.grab_focus()
