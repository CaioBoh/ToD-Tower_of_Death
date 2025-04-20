extends Path2D

@onready var dash_upgrade_area: Area2D = $PathFollow2D/DashUpgradeArea
@onready var path_follow_2d: PathFollow2D = $PathFollow2D
@onready var collision_shape: CollisionShape2D = $PathFollow2D/DashUpgradeArea/CollisionShape2D
@onready var dash_upgrade_particle: GPUParticles2D = $PathFollow2D/DashUpgradeParticle

signal dash_picked
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	path_follow_2d.progress_ratio+=0.008

func _on_dash_upgrade_area_body_entered(body: Node2D) -> void:
	Global.current_camera.start_shake(5,30,15)
	#self.visible = false;
	dash_upgrade_particle.emitting = false
	self.set_process(false)
	collision_shape.disabled = true
	Global.dash_picked = true
	dash_picked.emit()
	await get_tree().create_timer(3).timeout
	self.queue_free()
