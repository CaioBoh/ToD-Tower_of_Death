extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body == Global.global_player:
		if Global.key_picked:
			$Actionable.dialogue_start = "with_key"
		else:
			$Actionable.dialogue_start = "without_key"
		$Actionable.action()
