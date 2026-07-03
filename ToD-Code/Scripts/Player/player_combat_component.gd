extends Node
class_name player_combat_component

@export var SWORD_DAMAGE: int = 10
@export var KNOCKBACK_HIT_TAKEN: float = 1000
@export var KNOCKBACK_HIT_TAKEN_DURATION: float = 0.25
@export var KNOCKBACK_SWORD := Vector2(600, -70)
@export var KNOCKBACK_DEALT_DURATION: float = 0.2
@export var SWING_DURATION: float = 0.2
@export var TIME_SCALE_WHILE_HIT: float = 0.04
@export var TIME_SCALE_SHIFT_DURATION: float = 0.3
@export var slash_sound: AudioStreamPlayer
@export var invincible_timer: Timer
@export var hurt_sound: AudioStreamPlayer

var is_attacking: bool = false
var can_be_hit: bool = true

func handle_attack(physics_component: player_physics_component, animation_component: player_animation_component):
	if not Input.is_action_just_pressed("attack") or is_attacking or not Global.input_allowed:
		return

	var damage_collision_area_side: CollisionShape2D = physics_component.sword_area_side.get_node("CollisionShape2D")
	
	is_attacking = true
	
	animation_component.animation.play("Attack1")
	slash_sound.pitch_scale = 1 + randf_range(0, 1)
	slash_sound.play()
	
	await get_tree().create_timer(SWING_DURATION).timeout
	damage_collision_area_side.disabled = false
	var animation_duration: float = animation_component.animation.sprite_frames.get_frame_count("Attack1") / animation_component.animation.sprite_frames.get_animation_speed("Attack1")
	var hit_duration: float = animation_duration - SWING_DURATION
	await get_tree().create_timer(hit_duration).timeout
	damage_collision_area_side.disabled = true
		
	is_attacking = false
	
func hurt(player_body: CharacterBody2D, body, damage: int, animation_component: player_animation_component, physics_component: player_physics_component):	
	if not can_be_hit:
		return 0
		
	var damage_dealt: int = 0
	if(player_body.player_health > damage):
		can_be_hit = false
		invincible_timer.start()
		hurt_sound.play()
		animation_component.instantiate_hurt_particle(player_body.global_position)
		Global.change_time_scale_for_duration(TIME_SCALE_WHILE_HIT, TIME_SCALE_SHIFT_DURATION)
		
		var direction_to_body: Vector2 = player_body.global_position.direction_to(body.global_position)
		var knockback := Vector2(-direction_to_body.x, 0).normalized() * KNOCKBACK_HIT_TAKEN
		physics_component.apply_knockback(knockback, KNOCKBACK_HIT_TAKEN_DURATION)
		
		damage_dealt = damage
	else:
		damage_dealt = player_body.player_health

	return damage_dealt
	
func _on_sword_side_area_body_entered(body: CharacterBody2D):
	var player_body: CharacterBody2D = Global.global_player
	var p_script := player_body as player_script
	if body.has_method("hurt"):
		body.hurt(p_script, SWORD_DAMAGE)
		var direction_to_body: Vector2 = player_body.global_position.direction_to(body.global_position)
		p_script.physics_component.apply_knockback(Vector2(-direction_to_body.x * KNOCKBACK_SWORD.x, KNOCKBACK_SWORD.y), KNOCKBACK_DEALT_DURATION)

func _on_sword_side_area_area_entered(area: Area2D):
	var player_body: CharacterBody2D = Global.global_player
	var p_script := player_body as player_script
	if area.has_method("hurt"):
		area.hurt(p_script, SWORD_DAMAGE)
		var direction_to_area: Vector2 = player_body.global_position.direction_to(area.global_position)
		p_script.physics_component.apply_knockback(Vector2(-direction_to_area.x * KNOCKBACK_SWORD.x, -2000), KNOCKBACK_DEALT_DURATION)

func _on_sword_up_area_body_entered(body: CharacterBody2D):
	var p_script := Global.global_player as player_script
	if body.has_method("hurt"):
		body.hurt(p_script, SWORD_DAMAGE)
		
func _on_sword_up_area_area_entered(area: Area2D):
	var p_script := Global.global_player as player_script
	if area.has_method("hurt"):
		area.hurt(p_script, SWORD_DAMAGE)

func _on_invencible_timer_timeout():
	can_be_hit = true
