extends Control

@export var continueButton: Button
@export var optionsButton: Button
@export var quitButton: Button

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("cancel"):
		if SceneTransition.current_menu_state == SceneTransition.menu_state.PLAYING:
			pause_game()
		elif SceneTransition.current_menu_state == SceneTransition.menu_state.PAUSE_MENU:
			continue_game()
		
func pause_game():
	continueButton.grab_focus()
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
	pass

func _on_quit_pressed() -> void:
	get_tree().paused = false
	$CanvasLayer.visible = false
	if not SceneTransition.isTransitioning:
		SceneTransition.change_scene("res://game/UI/start_menu.tscn", SceneTransition.menu_state.START_MENU)
