extends Control

@export var playButton: Button
@export var exitButton: Button

func _ready():
	playButton.grab_focus()

func _on_play_pressed() -> void:
	SceneTransition.change_scene("res://game/levels/lobby/lobby.tscn")
	Global.reset()
	SceneTransition.current_menu_state = SceneTransition.menu_state.PLAYING
	
func _on_exit_pressed() -> void:
	get_tree().quit()
	
