extends Node

var collected = false

func _on_actionable_body_entered(body: Node2D) -> void:
	if body == Global.global_player and not collected:
		collected = true
		Global.collectibles_found += 1
		var balloon = $Actionable.action()
		await balloon.dialogue_finished
		queue_free()
