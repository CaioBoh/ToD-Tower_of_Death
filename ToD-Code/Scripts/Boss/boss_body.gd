extends AnimatedSprite2D

@onready var hands = $"../Hands"
var speed: float = 2

func _process(delta):
	if hands:
		global_position = lerp(global_position, hands.global_position, speed * delta)
