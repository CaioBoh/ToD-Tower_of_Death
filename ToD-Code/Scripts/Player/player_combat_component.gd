extends Node
class_name player_combat_component

var is_attacking := false
var can_be_hit := true

@export var slash_sound : AudioStreamPlayer
@export var invincible_timer : Timer
@export var hurt_sound : AudioStreamPlayer
@export var SWORD_DAMAGE := 10
@export var KNOCKBACK_HIT_TAKEN := 1000.0
@export var KNOCKBACK_HIT_TAKEN_DURATION := 0.25
@export var KNOCKBACK_SWORD := Vector2(600, -70)
@export var KNOCKBACK_DEALT_DURATION := 0.2
@export var SWING_DURATION := 0.2
@export var TIME_SCALE_WHILE_HIT := 0.04
@export var TIME_SCALE_SHIFT_DURATION := 0.3

func handle_attack(physics_component : player_physics_component, animation_component : player_animation_component):
	if not Input.is_action_just_pressed("attack") or is_attacking or not Global.input_allowed:
		return

	var damage_collision_area_side = physics_component.sword_area_side.get_node("CollisionShape2D")
	
	is_attacking = true
	
	animation_component.animation.play("Attack1")
	slash_sound.pitch_scale = 1 + randf_range(0, 1)
	slash_sound.play()
	
	await get_tree().create_timer(SWING_DURATION).timeout
	damage_collision_area_side.disabled = false
	var animation_duration := animation_component.animation.sprite_frames.get_frame_count("Attack1") / animation_component.animation.sprite_frames.get_animation_speed("Attack1")
	var hit_duration = animation_duration - SWING_DURATION
	await get_tree().create_timer(hit_duration).timeout
	damage_collision_area_side.disabled = true
		
	is_attacking = false
	
func hurt(player_body: CharacterBody2D, body, damage : int, animation_component: player_animation_component, physics_component: player_physics_component):
	var damage_dealt = 0
	
	if not can_be_hit:
		return
		
	if(player_body.player_health > damage):
		can_be_hit = false
		invincible_timer.start()
		hurt_sound.playing = true
		animation_component.instantiate_hurt_particle(player_body.global_position)
		Global.change_time_scale_for_duration(TIME_SCALE_WHILE_HIT, TIME_SCALE_SHIFT_DURATION)
		
		var direction_to_body = -player_body.global_position.direction_to(body.global_position)
		var knockback := Vector2(direction_to_body.x, 0).normalized() * KNOCKBACK_HIT_TAKEN
		physics_component.apply_knockback(knockback, KNOCKBACK_HIT_TAKEN_DURATION)
		
		damage_dealt = damage
	else:
		damage_dealt = player_body.player_health
		
	return damage_dealt
	
func _on_sword_side_area_body_entered(body):
	var player_body := Global.global_player as CharacterBody2D
	var p_script := player_body as player_script
	if body.has_method("hurt"):
		body.hurt(p_script, SWORD_DAMAGE)
		var direction_body = player_body.global_position.direction_to(body.global_position)
		p_script.physics_component.apply_knockback(Vector2(-direction_body.x * KNOCKBACK_SWORD.x, KNOCKBACK_SWORD.y), KNOCKBACK_DEALT_DURATION)

func _on_sword_side_area_area_entered(area):
	var player_body := Global.global_player as CharacterBody2D
	var p_script := player_body as player_script
	if area.has_method("hurt"):
		area.hurt(p_script, SWORD_DAMAGE)
		var direction_area = player_body.global_position.direction_to(area.global_position)
		p_script.physics_component.apply_knockback(Vector2(-direction_area.x * KNOCKBACK_SWORD.x, -2000), KNOCKBACK_DEALT_DURATION)

func _on_sword_up_area_body_entered(body):
	var p_script := Global.global_player as player_script
	if body.has_method("hurt"):
		body.hurt(p_script, SWORD_DAMAGE)
		
func _on_sword_up_area_area_entered(area: Area2D) -> void:
	var p_script := Global.global_player as player_script
	if area.has_method("hurt"):
		area.hurt(p_script, SWORD_DAMAGE)

func _on_invencible_timer_timeout():
	can_be_hit = true
