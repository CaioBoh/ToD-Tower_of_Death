extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body == Global.global_player:
		Global.key_picked = true
		print("key was picked")
		queue_free()
