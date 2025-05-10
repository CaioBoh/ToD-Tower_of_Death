extends GPUParticles2D
@onready var secondary_particles_2d = $GPUParticles2D
@onready var explosion_sound: AudioStreamPlayer2D = $ExplosionSound


# Called when the node enters the scene tree for the first time.
func _ready():
	secondary_particles_2d.emitting = true
	emitting = true
	explosion_sound.play()
	await get_tree().create_timer(3).timeout
	queue_free()
