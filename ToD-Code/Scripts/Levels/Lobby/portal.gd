extends Area2D

func _on_body_entered(_body: Node2D) -> void:
	Global.is_talking = false
	SceneTransition.change_scene("res://Scenes/Levels/level_1.tscn", SceneTransition.menu_state.PLAYING)
