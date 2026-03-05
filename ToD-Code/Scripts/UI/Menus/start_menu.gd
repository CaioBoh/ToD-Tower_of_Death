extends Node

@export var playButton: Button
@export var exitButton: Button
@export var optionsButton: Button
@export var demoNewGame: Button

var play_sound_effect: bool = false

func _ready():
	reset_focus()

func _on_play_pressed() -> void:
	if not SceneTransition.isTransitioning:
		toggleButtons(false)
	SceneTransition.change_scene("res://Scenes/Levels/lobby.tscn", SceneTransition.menu_state.PLAYING)
	ControlSoundEffects.play_play()
	Global.reset()
	
func _on_options_pressed() -> void:
	SceneTransition.current_menu_state = SceneTransition.menu_state.OPTIONS
	Options.options_canvas.visible = true
	Options.menu_state_to_return = SceneTransition.menu_state.START_MENU
	Options.reset_focus()
	ControlSoundEffects.play_click()
	play_sound_effect = false
	
func _on_exit_pressed() -> void:
	ControlSoundEffects.play_click()
	get_tree().quit()
	
func reset_focus():
	playButton.grab_focus()
	play_sound_effect = true
	
func _on_demo_novo_jogo_pressed() -> void:
	if not SceneTransition.isTransitioning:
		toggleButtons(false)
		
	SceneTransition.change_scene("res://Scenes/Levels/lobby.tscn", SceneTransition.menu_state.PLAYING)
	Global.reset_demo()
	ControlSoundEffects.play_play()
	
func toggleButtons(enabled: bool):
	playButton.disabled = not enabled
	exitButton.disabled = not enabled
	optionsButton.disabled = not enabled
	demoNewGame.disabled = not enabled


func _on_focus_entered() -> void:
	if play_sound_effect:
		ControlSoundEffects.play_change_focus()
