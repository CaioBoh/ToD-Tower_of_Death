extends Node

@onready var options_canvas: CanvasLayer = $CanvasLayer

@export var tab_container: TabContainer
@export var change_focus_effect: AudioStreamPlayer
@export var click_effect: AudioStreamPlayer
@export var cancel_effect: AudioStreamPlayer
@export var audios_sliders: Array[AudioSlider]

var play_sound_effect: bool = false
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
	SaveLoad.save_sound_data()
	SceneTransition.current_menu_state = menu_state_to_return
	$CanvasLayer.visible = false
	match menu_state_to_return:
		SceneTransition.menu_state.START_MENU:
			get_tree().current_scene.reset_focus()
		SceneTransition.menu_state.PAUSE_MENU:
			PauseMenu.pause_menu_canvas.visible = true
			PauseMenu.reset_focus()
	ControlSoundEffects.play_cancel()
	play_sound_effect = false
	
func reset_focus():
	tab_container.get_tab_bar().grab_focus()
	play_sound_effect = true

func _on_focus_entered() -> void:
	if play_sound_effect:
		ControlSoundEffects.play_change_focus()
		
