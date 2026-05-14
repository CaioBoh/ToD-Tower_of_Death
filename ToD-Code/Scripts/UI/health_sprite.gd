extends AnimatedSprite2D

func _process(delta: float) -> void:
	speed_scale = float(Global.global_player.MAX_PLAYER_HEALTH) / (Global.global_player.player_health * 2)
