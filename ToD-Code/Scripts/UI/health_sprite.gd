extends AnimatedSprite2D

func _process(delta: float) -> void:
	speed_scale = float(Global.global_player.max_player_health) / (Global.global_player.player_health * 2)
