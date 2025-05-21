extends Area2D

func _on_body_entered(_body: Node2D) -> void:
	Global.is_talking = false
	SceneTransition.change_scene("res://Scenes/Levels/level_1_edited.tscn", SceneTransition.menu_state.PLAYING)
