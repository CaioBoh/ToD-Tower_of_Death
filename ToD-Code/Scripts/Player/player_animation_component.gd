extends Node
class_name player_animation_component

@export var HURT_PARTICLE_SCALE: Vector2 = Vector2(0.7, 0.7)
@export var animation: AnimatedSprite2D
@export var animation_player: AnimationPlayer

func handle_animation(physics_component: player_physics_component, combat_component: player_combat_component, velocity: Vector2):
	if Global.disable_physics or combat_component.is_attacking:
		return
	
	if velocity.x == 0:
		animation.play("Atlas_idle")
	else:
		animation.play("Atlas_run")
	
func flip_sprite(physics_component: player_physics_component):
	if physics_component.looking_direction > 0:
		animation.flip_h = false
	elif physics_component.looking_direction < 0:
		animation.flip_h = true

func instantiate_hurt_particle(player_position: Vector2):
	var step: float = 2.5
	var initial_value: float = 5
	var num_of_steps: float = randi_range(0, 6)
	
	var hurt_particle_instance = Global.CROSS_HIT.instantiate()
	hurt_particle_instance.global_position = player_position
	hurt_particle_instance.scale = HURT_PARTICLE_SCALE
	var particle_rotation: float = (initial_value + num_of_steps) * step * [1, -1].pick_random()
	hurt_particle_instance.rotation_degrees = particle_rotation
	
	owner.add_child(hurt_particle_instance)
	animation_player.play("hurt_animation")
	
func instantiate_death_particle():
	var player: CharacterBody2D = Global.global_player
	var death_particle_instance: GPUParticles2D = Global.DEATH_PARTICLE_ATLAS.instantiate()
	owner.add_child(death_particle_instance)
	death_particle_instance.global_position = player.global_position
	death_particle_instance.emitting = true

func ascend():
	var height: float = 150
	var duration: float = 3
	
	var player: CharacterBody2D = Global.global_player
	var tween = create_tween()
	tween = tween.tween_property(player, "position:y", player.position.y - height, duration)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
