extends Node

@export var agradecimentos: Label
@export var coletaveis: Label
@export var botaoVoltar: Button

func show_messages():
	coletaveis.text = str(Global.collectibles_found) + "/3 coletáveis encontrados!"
	await get_tree().create_timer(2).timeout
	var tween = create_tween()
	tween.tween_property(agradecimentos, "modulate", Color(agradecimentos.modulate, 1), 1)
	tween.tween_property(coletaveis, "modulate", Color(coletaveis.modulate, 1), 1)
	tween.tween_property(botaoVoltar, "modulate", Color(botaoVoltar.modulate, 1), 1)
	
	await get_tree().create_timer(3).timeout
		
	botaoVoltar.disabled = false

func _on_button_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/UI/Menus/start_menu.tscn", SceneTransition.menu_state.START_MENU)
