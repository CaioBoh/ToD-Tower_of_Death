extends Area2D




func _on_body_entered(body: Node2D) -> void:
	if body == Global.global_player:
		Global.current_camera.limit_bottom = 590
