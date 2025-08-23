extends Path2D

@onready var sfx_upgrade: AudioStreamPlayer = $PathFollow2D/UpgradeArea/AudioStreamPlayer
@onready var dash_upgrade_area: Area2D = $PathFollow2D/UpgradeArea
@onready var path_follow_2d: PathFollow2D = $PathFollow2D
@onready var collision_shape: CollisionShape2D = $PathFollow2D/UpgradeArea/CollisionShape2D
@onready var dash_upgrade_particle: GPUParticles2D = $PathFollow2D/UpgradeParticle

@export var upgradeType: String

func _ready() -> void:
	if upgradeType == "dash" && Global.dash_picked:
		queue_free()
	elif upgradeType == "double_jump" && Global.double_jump_picked:
		queue_free()

func _process(delta: float) -> void:
	path_follow_2d.progress_ratio+=0.008

func _on_upgrade_area_body_entered(body: Node2D) -> void:
	sfx_upgrade.play()
	Global.current_camera.start_shake(5,30,15)
	#self.visible = false;
	dash_upgrade_particle.emitting = false
	self.set_process(false)
	collision_shape.disabled = true
	Global.receive_upgrade(upgradeType)
	Global.global_player.on_upgrade_picked()
	await get_tree().create_timer(6.7).timeout
	self.queue_free()
