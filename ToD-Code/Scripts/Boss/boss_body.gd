extends AnimatedSprite2D
@onready var hands = $"../Hands"
var direction


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hands:
		global_position = lerp(global_position,hands.global_position,delta * 3)
