extends Node
class_name player_physics_component

@export var sword_area_side: Area2D
@export var sword_area_up: Area2D
@export var max_height_stairs: RayCast2D
@export var is_there_stairs: RayCast2D
@export var is_touching_floor: RayCast2D
@export var ledge_forgiveness_timer: Timer

@export var SPEED : float = 250.0
@export var JUMP_VELOCITY : float = -500
@export var STEP_UP_VELOCITY : float = 18

var looking_direction := 1
var jump_state := enums.JumpState.GROUNDED
var ledge_forgiveness_active := false
var knockback_vector : Vector2 = Vector2.ZERO
var GRAVITY: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func flip_areas():
	sword_area_side.scale.x = looking_direction
	max_height_stairs.position.x = 1.5 + looking_direction * 12.5
	max_height_stairs.scale.x = looking_direction
	is_there_stairs.scale.x = looking_direction
	is_touching_floor.scale.x = looking_direction
	
func apply_knockback(new_knockback : Vector2, duration : float):
	knockback_vector = new_knockback
	var knockback_tween = get_tree().create_tween()
	knockback_tween.tween_property(self, "knockback_vector", Vector2.ZERO, duration)
	
func handle_stairs_up(player_body: CharacterBody2D):
	if player_body.velocity.x != 0 and is_touching_floor.is_colliding() and is_there_stairs.is_colliding() and not max_height_stairs.is_colliding():
		player_body.position.y -= STEP_UP_VELOCITY
		
	
func jump(delta, is_on_floor: bool, player_body: CharacterBody2D):
	if Global.disable_physics:
		return
	if not is_on_floor:
		player_body.velocity.y += GRAVITY * delta
		if jump_state == enums.JumpState.GROUNDED:
			jump_state = enums.JumpState.FIRST_JUMP
			ledge_forgiveness_active = true
			ledge_forgiveness_timer.start()
	else:
		jump_state = enums.JumpState.GROUNDED
		ledge_forgiveness_active = false
		ledge_forgiveness_timer.stop()
	
	if Input.is_action_just_pressed("jump") and Global.input_allowed and not Global.is_talking:
		if jump_state == enums.JumpState.GROUNDED || ledge_forgiveness_active:
			player_body.velocity.y = JUMP_VELOCITY
			jump_state = enums.JumpState.FIRST_JUMP
			ledge_forgiveness_active = false
		elif jump_state == enums.JumpState.FIRST_JUMP && Global.double_jump_picked:
			player_body.velocity.y = JUMP_VELOCITY
			jump_state = enums.JumpState.SECOND_JUMP
			
func move(player_body: CharacterBody2D):
	if not Global.input_allowed or Global.disable_physics:
		return
	var direction = Input.get_axis("left", "right") as int
	if Global.is_talking:
		player_body.velocity.x = 0
	elif knockback_vector != Vector2.ZERO:
		player_body.velocity = knockback_vector
		print(knockback_vector)
	else:
		player_body.velocity.x = direction * SPEED

	if direction != 0:
		looking_direction = direction
		
func _on_ledge_forgiveness_timer_timeout():
	ledge_forgiveness_active = false
