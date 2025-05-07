extends GPUParticles2D

func _ready():
	self.emitting = true
	await get_tree().create_timer(3).timeout
	queue_free()
