extends Node
class_name player_animation_component

@export var animation: AnimatedSprite2D
@export var animation_player: AnimationPlayer

func handle_animation(physics_component : player_physics_component, combat_component : player_combat_component, velocity : Vector2):
	if Global.disable_physics or combat_component.is_attacking:
		return
	
	if velocity.x == 0:
		animation.play("Atlas_idle")
	else:
		animation.play("Atlas_run")
	
func flip_sprite(physics_component : player_physics_component):
	if physics_component.looking_direction == 1:
		animation.flip_h = false
	elif physics_component.looking_direction == -1:
		animation.flip_h = true

func instantiate_hurt_particle(player_position: Vector2):
	var hurt_particle_instance = Global.CROSS_HIT.instantiate()
	hurt_particle_instance.global_position = player_position
	hurt_particle_instance.scale = Vector2(0.7,0.7)
	hurt_particle_instance.rotation_degrees = [5,7.5,10,12.5,15,17.5,20,-5,-7.5,-10,-12.5,-15.0,-17.5,-20].pick_random()
	owner.owner.add_child(hurt_particle_instance)
	animation_player.play("hurt_animation")
	
func instantiate_death_particle():
	var player := Global.global_player as CharacterBody2D
	var instance = Global.DEATH_PARTICLE_ATLAS.instantiate()
	instance.global_position = player.global_position
	instance.emitting = true
	owner.owner.add_child(instance)

func ascend():
	var player := Global.global_player as CharacterBody2D
	var tween = create_tween()
	tween = tween.tween_property(player, "position:y", player.position.y - 150, 3)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
