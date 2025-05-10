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

const HIT_PARTICLE = preload("res://Scenes/Particles/hit_particle_2.tscn")

@onready var walk_time = $WalkTime
@onready var sight_ray_1 = $SightRay1
@onready var spear_range = $SpearRange
@onready var hit_box = $HitBox
@onready var attack_delay = $AttackDelay
@onready var animated_sprite_2d = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	player = Global.global_player
	is_chasing = false
	is_attacking = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector
	else:
		velocity.x = dir * speed * delta * 5
	#print(velocity.x)
	handle_movement()
	handle_animation()
	move_and_slide()


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
#	print(velocity.x)

	if dir == 1:
		animated_sprite_2d.flip_h = false
	elif dir == -1:
		animated_sprite_2d.flip_h = true
	
	if velocity.x < -1:
		sight_ray_1.scale.x = -1
		hit_box.scale.x = -1
		spear_range.scale.x = -1
	elif velocity.x > 1:
		sight_ray_1.scale.x = 1
		hit_box.scale.x = 1
		spear_range.scale.x = 1
	if velocity.x < 1 and velocity.x > -1 and !is_chasing and not is_attacking:
		if animated_sprite_2d.animation != "transition_to_attack":
			animated_sprite_2d.play("idle")
	elif !is_attacking: 
		if animated_sprite_2d.animation != "transition_to_attack":
			if animated_sprite_2d.animation == "attack":
				await animated_sprite_2d.animation_finished
			animated_sprite_2d.play("walking")

func handle_movement():
	var last_animation = animated_sprite_2d.animation
	if sight_ray_1.is_colliding():
		if sight_ray_1.get_collider() == player:
			is_chasing = true
			walk_time.stop()
			#current_state = state.CHASING
	
	if Global.is_player_dead:
		is_chasing = false
	
	if is_chasing and !player_on_spear_range and !is_attacking and last_animation != "transition_to_attack":
		
		dir = position.direction_to(player.global_position).x
		dir = dir / abs(dir)
		await animated_sprite_2d.animation_finished
		if animated_sprite_2d.animation != "transition_to_attack":
			animated_sprite_2d.play("walking")
	elif player_on_spear_range:
		dir = 0;

func _on_spear_range_body_entered(body):
	if body == player:
		walk_time.stop()
		player_on_spear_range = true
		animated_sprite_2d.play("transition_to_attack")
		await animated_sprite_2d.animation_finished
		attack_delay.start()
		is_attacking = true

func _on_spear_range_body_exited(body):
	if body == player:
		player_on_spear_range = false
		is_chasing = true


func _on_attack_delay_timeout():
	if is_attacking:
#		print("attack delay finished")
		walk_time.stop()
		var collision_shape = hit_box.get_node("CollisionShape2D")
		animated_sprite_2d.play("attack")
		await get_tree().create_timer(.2).timeout
		collision_shape.disabled = false
		if Global.is_player_dead:
			return
		await get_tree().create_timer(.1).timeout
		collision_shape.disabled = true
		if !player_on_spear_range:
			is_attacking = false
		else:
			await animated_sprite_2d.animation_finished
			attack_delay.start()


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.has_method("hurt"):
		body.hurt(self,70)

func hurt(body,damage):
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
