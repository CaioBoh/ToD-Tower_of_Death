extends Area2D

func _ready() -> void:
	if Global.key_picked:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == Global.global_player:
		Global.key_picked = true
		print("key was picked")
		$Actionable.action()
		queue_free()
