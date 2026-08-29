extends Node

@onready var pause_menu_canvas: CanvasLayer = $CanvasLayer

@export var continueButton: Button
@export var optionsButton: Button
@export var quitButton: Button

var focused_control: Control

var play_sound_effect: bool = false

func _ready() -> void:
	pause_menu_canvas.visible = false

func _input(event: InputEvent):
	if event.is_action_pressed("cancel") and not Debug.debug_menu_active:
		print(Debug.debug_menu_active)
		if SceneTransition.current_menu_state == SceneTransition.menu_state.PLAYING:
			pause_game()
		elif SceneTransition.current_menu_state == SceneTransition.menu_state.PAUSE_MENU:
			continue_game()
		
func pause_game():
	focused_control = get_viewport().gui_get_focus_owner()
	reset_focus()
	$CanvasLayer.visible = true
	get_tree().paused = true
	SceneTransition.current_menu_state = SceneTransition.menu_state.PAUSE_MENU
	
func continue_game():
	$CanvasLayer.visible = false
	get_tree().paused = false
	SceneTransition.current_menu_state = SceneTransition.menu_state.PLAYING
	ControlSoundEffects.play_click()
	play_sound_effect = false
	
	if is_instance_valid(focused_control):
		focused_control.grab_focus()
		focused_control = null
	
func _on_continue_pressed() -> void:
	continue_game()
	
func _on_options_pressed() -> void:
	SceneTransition.current_menu_state = SceneTransition.menu_state.OPTIONS
	$CanvasLayer.visible = false
	Options.options_canvas.visible = true
	Options.menu_state_to_return = SceneTransition.menu_state.PAUSE_MENU
	Options.reset_focus()
	ControlSoundEffects.play_click()
	play_sound_effect = false

func _on_quit_pressed() -> void:
	Global.returned_to_menu.emit()
	get_tree().paused = false
	$CanvasLayer.visible = false
	SaveLoad.save_game_data()
	Global.first_time_spawning = true
	SceneTransition.change_scene("res://Scenes/UI/Menus/start_menu.tscn", SceneTransition.menu_state.START_MENU)
	ControlSoundEffects.play_click()
	play_sound_effect = false
		
func reset_focus():
	continueButton.grab_focus()
	play_sound_effect = true
	
func _on_focus_entered() -> void:
	if play_sound_effect:
		ControlSoundEffects.play_change_focus()
