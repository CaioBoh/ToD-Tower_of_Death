extends GPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready():
	self.emitting = true
	await get_tree().create_timer(3).timeout
	queue_free()
