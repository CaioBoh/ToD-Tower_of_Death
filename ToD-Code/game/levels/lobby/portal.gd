extends Area2D

func _on_body_entered(_body: Node2D) -> void:
	Global.is_talking = false
	SceneTransition.change_scene("res://game/levels/first_level/first_level.tscn", SceneTransition.menu_state.PLAYING)
