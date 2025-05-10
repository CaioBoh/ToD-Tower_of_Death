extends AnimatedSprite2D

func _process(delta: float) -> void:
	speed_scale = float(Global.max_player_health) / (Global.player_health * 2)
