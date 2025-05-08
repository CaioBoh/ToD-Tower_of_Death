extends Node

@export var playButton: Button
@export var exitButton: Button

func _ready():
	reset_focus()

func _on_play_pressed() -> void:
	SceneTransition.change_scene("res://game/levels/lobby/lobby.tscn", SceneTransition.menu_state.PLAYING)
	Global.reset()
	
func _on_options_pressed() -> void:
	SceneTransition.current_menu_state = SceneTransition.menu_state.OPTIONS
	Options.options_canvas.visible = true
	Options.menu_state_to_return = SceneTransition.menu_state.START_MENU
	Options.reset_focus()
	
func _on_exit_pressed() -> void:
	get_tree().quit()
	
func reset_focus():
	playButton.grab_focus()
	
