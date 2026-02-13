extends Node

@export var playButton: Button
@export var exitButton: Button
@export var optionsButton: Button
@export var demoNewGame: Button

@onready var cursor = $CanvasLayer/Cursor
@onready var buttons = $CanvasLayer/CenterContainer/Buttons

var play_sound_effect: bool = true


func _ready():
	# Garante que os botões aceitam foco por teclado/controle
	for child in buttons.get_children():
		if child is Button:
			child.focus_mode = Control.FOCUS_ALL

	# Dá foco inicial no primeiro botão
	await get_tree().process_frame
	if buttons.get_child_count() > 0:
		var first_button := buttons.get_child(0) as Button
		first_button.grab_focus()

func _on_demo_novo_jogo_pressed() -> void:
	if not SceneTransition.isTransitioning:
		toggleButtons(false)
		
	SceneTransition.change_scene("res://Scenes/Levels/lobby.tscn", SceneTransition.menu_state.PLAYING)
	Global.reset_demo()
	ControlSoundEffects.play_play()
	
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

func toggleButtons(enabled: bool):
	playButton.disabled = not enabled
	exitButton.disabled = not enabled
	optionsButton.disabled = not enabled
	demoNewGame.disabled = not enabled


func _on_focus_entered() -> void:
	var button := get_viewport().gui_get_focus_owner() as Control
	if not button:
		return

	var rect := button.get_global_rect()
	var target_y := rect.position.y + rect.size.y * 0.5

	cursor.global_position.y = target_y

	var screen_pos := button.get_screen_position()
	cursor.position.y = screen_pos.y + button.size.y * 0.5
	if play_sound_effect:
		ControlSoundEffects.play_change_focus()
