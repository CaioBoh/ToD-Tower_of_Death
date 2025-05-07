extends Area2D

var has_key = false

func _on_body_entered(body: Node2D) -> void:
	has_key = Global.key_picked
	if body == Global.global_player and has_key:
		get_tree().change_scene_to_file("res://game/levels/boss_room.tscn")
