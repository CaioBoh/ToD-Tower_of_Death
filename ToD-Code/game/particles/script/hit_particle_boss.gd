extends GPUParticles2D

var hand_to_seek
# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(2).timeout
	queue_free()

func _process(delta):
	if hand_to_seek:
		global_position = hand_to_seek.global_position

func set_body(body):
	hand_to_seek = body
