extends GPUParticles2D

class_name SimpleOneshotParticle

func _ready() -> void:
	emitting = true
	destroy()
func destroy():
	await finished
	queue_free()
