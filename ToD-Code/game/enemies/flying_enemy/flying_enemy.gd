extends CharacterBody2D

@onready var anim = $anim
const SPEED = 10000.0
var health = 20
var gravity = 0.0
var player
var dead = false
var chasing = false
var is_dashing = false
var knockback_vector = Vector2.ZERO
var dash_vector = Vector2.ZERO
var soul_particle = preload("res://game/particles/scene/hit_particle.tscn")
var death_particle = preload("res://game/particles/scene/death_enemy_explosion_particle.tscn")
@onready var sight_area = $SightArea
@onready var animated_sprite = $AnimatedSprite2D
@onready var dash_area: Area2D = $DashArea
@onready var sprites: AnimatedSprite2D = $AnimatedSprite2D

var bounce_tween: Tween



func _ready():
	player = Global.global_player
	anim.play("RESET")

func _physics_process(delta):
	
	velocity.y += gravity
	
	if knockback_vector != Vector2.ZERO: #(0,0)
		velocity = knockback_vector * 25
	elif dash_vector != Vector2.ZERO:
		velocity = dash_vector * 10
	elif chasing:
		chase(delta)
	move_and_slide()
	
func chase(delta):
	if not dead and not Global.is_player_dead:
		var dir = global_position.direction_to(player.global_position)
		velocity = dir * SPEED * delta
		handle_animation(dir)


func _on_sight_area_body_entered(body):
	if body == player:
		chasing = true

func hurt(body, damage):
	
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
	var soul_instance = soul_particle.instantiate()
	soul_instance.global_position = global_position
	soul_instance.rotation = (knockback_vector).angle()
	soul_instance.emitting = true
	if health - damage > 0:
		health-=damage
		anim.play("hurt")
		add_child(soul_instance)
		Global.freeze_time(0.0,0.1)
		var knockback_tween:= get_tree().create_tween()
		knockback_tween.tween_property(self,"knockback_vector", Vector2.ZERO,0.25)	
	else:
		add_child(soul_instance)
		anim.play("death")
		var knockback_tween:= get_tree().create_tween()
		knockback_tween.tween_property(self,"knockback_vector", Vector2.ZERO,0.1)	
		chasing = false


func _on_dash_area_body_entered(body):
	if body == player and not is_dashing and not dead:
		chasing = false
		is_dashing = true
		dash()



func dash():
	chasing = false
	velocity = position.direction_to(player.global_position) * -200
	var player_last_pos = player.global_position
	await get_tree().create_timer(0.7).timeout
	dash_vector = player_last_pos - global_position
	var dash_tween:= get_tree().create_tween()
	dash_tween.tween_property(self,"dash_vector",Vector2.ZERO, 0.2)
	await get_tree().create_timer(0.5).timeout
	chasing = true
	is_dashing = false


func _on_collision_area_body_entered(body):
	if body==player:
		body.hurt(self,10)
		knockback_vector = player.global_position.direction_to(global_position) * 30
		var knockback_tween:= get_tree().create_tween()
		knockback_tween.tween_property(self,"knockback_vector", Vector2.ZERO,0.25)

func handle_animation(dir):
	if dir.x > 0:
		animated_sprite.flip_h = true
	if dir.x < 0:
		animated_sprite.flip_h = false

func death_properties():
	dead = true
	gravity = 10
	animated_sprite.stop()
	sight_area.monitoring = false
	dash_area.monitoring = false
	chasing = false

func get_invisible():
	animated_sprite.visible = false

func summon_death_particle():
	var soul_instance = death_particle.instantiate()
	soul_instance.global_position = global_position
	soul_instance.emitting = true
	get_parent().add_child(soul_instance)
	
func create_bounce():
	if bounce_tween and bounce_tween.is_running():
		bounce_tween.kill()
	bounce_tween = create_tween()

func play_death_sound():
	$DeathSound.play()
