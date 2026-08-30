extends CharacterBody2D

@onready var animation = $animation
@export var SPEED : float = 10000
@export var MAX_HEALTH : int = 20
@export var DASH_SPEED : float = 3000
@export var DASH_PREPARATION_SPEED : float = -200

@onready var spawn_point = global_position
@onready var sight_area = $SightArea
@onready var animated_sprite = $AnimatedSprite2D
@onready var dash_area: Area2D = $DashArea
@onready var sprites: AnimatedSprite2D = $AnimatedSprite2D

var health = MAX_HEALTH
var gravity = 0.0
var dead = false
var chasing = false
var is_dashing = false
var knockback_vector = Vector2.ZERO
var dash_vector = Vector2.ZERO
var returning_to_spawn = false
var bounce_tween: Tween

func _ready():
	animation.play("RESET")
	if not Debug.enemy_detection:
		_debug_toggle_player_detection()

func _physics_process(delta):
	if Global.is_talking or Global.disable_physics:
		return
	if knockback_vector != Vector2.ZERO: 
		velocity = knockback_vector * 25
	elif dash_vector != Vector2.ZERO:
		velocity = dash_vector
	elif chasing:
		chase(delta)
	elif returning_to_spawn:
		if global_position.distance_to(spawn_point) <= 20:
			global_position = spawn_point
			velocity = Vector2.ZERO
			returning_to_spawn = false
		velocity = global_position.direction_to(spawn_point) * 300
		var dir = global_position.direction_to(spawn_point)
		handle_animation(dir)
	elif dead:
		velocity.x = 0
	velocity.y += gravity * delta
	move_and_slide()
	
func chase(delta):
	if not dead and not Global.is_player_dead:
		var dir = global_position.direction_to(Global.global_player.global_position)
		velocity = dir * SPEED * delta
		handle_animation(dir)

func hurt(body, damage):
	dash_vector = Vector2.ZERO
	
	create_bounce()
	bounce_tween.tween_property(sprites,"scale", Vector2(0.56 * 1.35,0.56 * 1.35),0.2) \
				.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	bounce_tween.parallel().tween_property(sprites,"rotation_degrees",randf_range(-10.0,10.0),0.2) \
				.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	bounce_tween.tween_property(sprites,"scale", Vector2(0.56,0.56),0.2) \
				.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	bounce_tween.parallel().tween_property(sprites,"rotation_degrees",0,0.2) \
				.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	$HurtSound.play()
	knockback_vector = global_position - body.global_position
	var soul_instance = PreloadedScenes.soul_particle.instantiate()
	add_child(soul_instance)
	soul_instance.rotation = (knockback_vector).angle()	
	soul_instance.global_position = global_position
	var knockback_tween:= get_tree().create_tween()
	if health - damage > 0:
		health -= damage
		animation.play("hurt")
		Global.change_time_scale_for_duration(0.0,0.1)
		knockback_tween.tween_property(self,"knockback_vector", Vector2.ZERO,0.25)	
	else:
		knockback_tween.tween_property(self,"knockback_vector", Vector2.ZERO,0.1)	
		animation.play("death")
		chasing = false

func dash():
	var directionToPlayer := position.direction_to(Global.global_player.global_position)
	velocity = directionToPlayer * DASH_PREPARATION_SPEED
	await get_tree().create_timer(0.7).timeout
	dash_vector = directionToPlayer * DASH_SPEED
	var dash_tween:= get_tree().create_tween()
	dash_tween.tween_property(self,"dash_vector",Vector2.ZERO, 0.2)
	await get_tree().create_timer(0.5).timeout
	if not returning_to_spawn:
		chasing = true
	is_dashing = false

func handle_animation(dir):
	if dir.x > 0:
		animated_sprite.flip_h = true
	if dir.x < 0:
		animated_sprite.flip_h = false

func death_properties():
	dead = true
	gravity = 1000
	animated_sprite.stop()
	sight_area.monitoring = false
	dash_area.monitoring = false
	chasing = false
	$CollisionArea.set_deferred("monitoring", false)
	velocity = Vector2.ZERO
	collision_mask = 2

func get_invisible():
	animated_sprite.visible = false

func summon_death_particle():
	var soul_instance = PreloadedScenes.death_particle.instantiate()
	get_tree().current_scene.add_child(soul_instance)
	soul_instance.global_position = global_position
	
func create_bounce():
	if bounce_tween and bounce_tween.is_running():
		bounce_tween.kill()
	bounce_tween = create_tween()
	
func _on_sight_area_body_entered(body):
	if body == Global.global_player:
		chasing = true
		
func _on_escape_area_body_exited(body: Node2D) -> void:
	if body == Global.global_player:
		chasing = false
		returning_to_spawn = true
		
func _on_collision_area_body_entered(body):
	if body == Global.global_player:
		body.hurt(self,10)
		knockback_vector = Global.global_player.global_position.direction_to(global_position) * 30
		var knockback_tween:= get_tree().create_tween()
		knockback_tween.tween_property(self,"knockback_vector", Vector2.ZERO,0.25)
		
func _on_dash_area_body_entered(body):
	if body == Global.global_player and not is_dashing and not dead:
		chasing = false
		is_dashing = true
		dash()
		
func _debug_toggle_player_detection():
	var sight_area: Area2D = get_node("SightArea")
	var dash_area: Area2D = get_node("DashArea")
	sight_area.monitoring = not sight_area.monitoring
	dash_area.monitoring = not dash_area.monitoring
	
	if chasing or is_dashing:
		_on_escape_area_body_exited(Global.global_player)
		dash_vector = Vector2.ZERO
		
