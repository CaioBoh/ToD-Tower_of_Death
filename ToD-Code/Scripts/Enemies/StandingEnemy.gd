extends CharacterBody2D

var dir: float
const speed = 900.0
const JUMP_VELOCITY = -400.0
var is_chasing = false
var is_attacking = false
var is_player_dead = false
var player
var health = 60
var player_on_spear_range = false
var knockback_vector: Vector2 = Vector2.ZERO
var stop_attacking: bool = false
var is_waiting_to_attack: bool = false
var animation_ended: bool = false

const HIT_PARTICLE = preload("res://Scenes/Particles/hit_particle_2.tscn")

@onready var walk_time = $WalkTime
@onready var sight_ray_1 = $SightRay1
@onready var spear_range = $SpearRange
@onready var hit_box = $HitBox
@onready var attack_delay = $AttackDelay
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var is_there_floor: RayCast2D = $"Raycasts/IsThereFloor"
@onready var is_there_stairs: RayCast2D = $"Raycasts/IsThereStairs"
@onready var max_height_stairs: RayCast2D = $"Raycasts/MaxHeightStairs"
@onready var raycasts_parent: Node2D = $Raycasts

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	player = Global.global_player
	is_chasing = false
	is_attacking = false
	handle_stairs()

func _physics_process(delta):
	if Global.is_talking || Global.global_player.disable_physics:
		return
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector
	else:
		if is_there_floor.is_colliding() and not player_on_spear_range and not is_attacking and animated_sprite_2d.animation != "transition_to_attack":
			velocity.x = dir * speed * delta * 5
		else:
			velocity.x = 0

	handle_movement()
	handle_animation()
	move_and_slide()

func handle_stairs():
	if is_there_stairs.is_colliding() and not max_height_stairs.is_colliding():
			position.y -= 19
	await get_tree().create_timer(0.5).timeout
	handle_stairs()

func _on_walk_time_timeout():
	if !is_chasing and !is_attacking:
		dir = 0
#		print("walked a little from idle")
		walk_time.wait_time = choose([1,1.5,2])
		dir = choose([-1,1,0.5,-0.5,0.25,-0.25,0,0,0])
	
func choose(array):
	array.shuffle()
	return array.front()
	
func handle_animation():
	if dir > 0:
		animated_sprite_2d.flip_h = false
		sight_ray_1.scale.x = 1
		hit_box.scale.x = 1
		spear_range.scale.x = 1
		raycasts_parent.scale.x = 1
	elif dir < 0:
		animated_sprite_2d.flip_h = true
		sight_ray_1.scale.x = -1
		hit_box.scale.x = -1
		spear_range.scale.x = -1
		raycasts_parent.scale.x = -1

	if is_attacking:
		return
		
	if velocity.x < 1 and velocity.x > -1 and not is_chasing:
		if animated_sprite_2d.animation != "transition_to_attack":
			animated_sprite_2d.play("idle")
	else: 
		if animated_sprite_2d.animation != "transition_to_attack":
			animated_sprite_2d.play("walking")

func handle_movement():
	if sight_ray_1.is_colliding():
		if sight_ray_1.get_collider() == player:
			is_chasing = true
			walk_time.stop()
			#current_state = state.CHASING
	
	if Global.is_player_dead:
		is_chasing = false
	
	if is_chasing and not is_attacking and animated_sprite_2d.animation != "transition_to_attack":
		look_to_player()

func _on_spear_range_body_entered(body):
	if body == player:
		player_on_spear_range = true
		if is_attacking:
			is_waiting_to_attack = true
			return
		walk_time.stop()
		animated_sprite_2d.play("transition_to_attack")
		
		while not animation_ended:
			if stop_attack():
				return
			await get_tree().create_timer(0.05).timeout
			
		animation_ended = false
		attack_delay.start()
		is_attacking = true

func _on_spear_range_body_exited(body):
	if body == player:
		player_on_spear_range = false

func _on_attack_delay_timeout():
	walk_time.stop()
	var collision_shape = hit_box.get_node("CollisionShape2D")
	
	if stop_attack():
		return
		
	animated_sprite_2d.play("attack")
	await get_tree().create_timer(.2).timeout
	
	if stop_attack():
		return
			
	collision_shape.disabled = false
	if Global.is_player_dead:
		return
	await get_tree().create_timer(.1).timeout
	collision_shape.disabled = true
	
	while not animation_ended:
		if stop_attack():
			return
		await get_tree().create_timer(0.05).timeout
		
	animation_ended = false
	
	if player_on_spear_range or is_waiting_to_attack:
		is_attacking = true
		is_waiting_to_attack = false
		look_to_player()
		attack_delay.start()
	elif not player_on_spear_range:
		is_attacking = false

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.has_method("hurt"):
		body.hurt(self,30)

func hurt(body,damage):
	stop_attacking = true
	animated_sprite_2d.play("idle")
	health-=damage
	knockback_vector = body.global_position.direction_to(global_position) * 1000 + Vector2(0,-100)
	var knockback_tween:= get_tree().create_tween()
	knockback_tween.tween_property(self,"knockback_vector", Vector2.ZERO,0.25)
	summon_hurt_particle()
	$AnimationPlayer.play("hurt")
	var sound = choose([$HurtSound1, $HurtSound2])
	sound.playing = true
	
	if health<=0:
		queue_free()
		
func _on_animation_changed():
	#print("animation changed to:" + animated_sprite_2d.animation)
	pass
	

func summon_hurt_particle() -> void:
	var instance = HIT_PARTICLE.instantiate()
	instance.position = Vector2.ZERO
	instance.emitting = true
	var direction_player = global_position.direction_to(player.global_position)
	instance.rotation = Vector2(-direction_player.x, 0).angle()
	add_child(instance)

func _on_chase_area_body_exited(body: Node2D) -> void:
	if body == player:
		is_chasing = false
		velocity.x = 0
		dir = 0
		walk_time.start()

func look_to_player():
	if abs(global_position.x - player.global_position.x) < 10:
		dir = 0
	else:
		dir = position.direction_to(player.global_position).x
		dir = dir / abs(dir)
		
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "transition_to_attack" or is_attacking:
		animation_ended = true
		
func stop_attack():
	if stop_attacking:
		stop_attacking = false
		is_waiting_to_attack = false
		is_attacking = false
		animated_sprite_2d.play("idle")
		return true
	return false
