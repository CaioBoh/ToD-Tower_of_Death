extends Node2D

@onready var left_hand = $Left_Hand
@onready var right_hand = $Right_Hand
@onready var sprite_left_hand = $Left_Hand/Sprite_Left_Hand
@onready var sprite_right_hand = $Right_Hand/Sprite_Right_Hand
@onready var juice_anim = $JuiceAnimations
@onready var attacks_anim = $AnimationPlayer
@onready var boss_body = $"../AnimatedSprite2D"
@onready var hit_ground_single_wave_sound: AudioStreamPlayer2D = $hit_ground_single_wave_sound
@onready var hit_ground_double_wave_sound: AudioStreamPlayer2D = $hit_ground_double_wave_sound
@onready var hit_ground_single_sound: AudioStreamPlayer2D = $hit_ground_single_sound
@onready var hit_ground_double_sound: AudioStreamPlayer2D = $hit_ground_double_sound

const HIT_PARTICLE = preload("res://Scenes/Particles/hit_particle_boss.tscn")
const BOSS_DEATH_EXPLOSION = preload("res://Scenes/Particles/boss_death_explosion.tscn")

var direction : Vector2
var speed = 550
var bounce_tween: Tween
var damage: int = 10

signal damaged

func _ready():
	direction.x = 1
	
func _physics_process(delta):
	position += direction * speed * delta
	
func _on_right_detector_area_entered(area):
	if area.get_name() == "RightLimit":
		direction.x = -1

func _on_left_detector_area_entered(area):
	if area.get_name() == "LeftLimit":
		direction.x = 1

func _on_hitbox_body_entered(body):
	if body == Global.global_player:
		body.hurt(left_hand, damage)

func _on_hitbox_2_body_entered(body):
	if body == Global.global_player:
		body.hurt(right_hand, damage)

func create_bounce():
	if bounce_tween and bounce_tween.is_running():
		bounce_tween.kill()
	bounce_tween = create_tween()

func _on_hitbox_2_hitted():
	damaged.emit()
	## now i will do the bounce thing:
	create_bounce()
	bounce_tween.tween_property(sprite_right_hand,"scale", Vector2(2.267*1.15,2.267*1.15),0.2) \
				.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	bounce_tween.parallel().tween_property(sprite_right_hand,"rotation_degrees",randf_range(-10.0,10.0),0.2) \
				.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	bounce_tween.tween_property(sprite_right_hand,"scale", Vector2(2.267,2.267),0.2) \
				.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	bounce_tween.parallel().tween_property(sprite_right_hand,"rotation_degrees",0,0.2) \
				.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	## Now i will spawn particles:
	
	var soul_instance = HIT_PARTICLE.instantiate()
	add_child(soul_instance)
	print(sprite_right_hand.position)
	print(sprite_right_hand.global_position)
	print(soul_instance.global_position)
	juice_anim.play("right_hurt")
	soul_instance.global_position = right_hand.global_position
	soul_instance.rotation = (right_hand.global_position - Global.global_player.global_position).angle()
	soul_instance.emitting = true
	Global.change_time_scale_for_duration(0.0,0.1)

func _on_hitbox_hitted():
	damaged.emit()
	## now i will do the bounce thing:
	create_bounce()
	bounce_tween.tween_property(sprite_left_hand,"scale", Vector2(2.267*1.15,2.267*1.15),0.2) \
				.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	bounce_tween.parallel().tween_property(sprite_left_hand,"rotation_degrees",randf_range(-10.0,10.0),0.2) \
				.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	bounce_tween.tween_property(sprite_left_hand,"scale", Vector2(2.267,2.267),0.2) \
				.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	bounce_tween.parallel().tween_property(sprite_left_hand,"rotation_degrees",0,0.2) \
				.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	## Now i will spawn particles:
	
	var soul_instance = HIT_PARTICLE.instantiate()
	add_child(soul_instance)
	juice_anim.play("left_hurt")
	soul_instance.global_position = left_hand.global_position
	soul_instance.rotation = (left_hand.global_position - Global.global_player.global_position).angle()
	soul_instance.emitting = true
	Global.change_time_scale_for_duration(0.0,0.1)

func _on_first_boss_dead():
	attacks_anim.pause()
	await get_tree().create_timer(10).timeout
	var explosion_instance = BOSS_DEATH_EXPLOSION.instantiate()
	get_parent().get_parent().add_child(explosion_instance)
	explosion_instance.global_position = boss_body.global_position
	explosion_instance.z_index = 4
	Global.current_camera.start_shake(5,20,20)
	
	#Demo
	print(get_tree().root.name)
	
	get_parent().get_parent().find_child("Demo").show_messages()
	boss_body.get_parent().queue_free()
	
# Funcs below to access through animation

func play_hit_ground_single_wave_sound():
	hit_ground_single_wave_sound.play()

func play_hit_ground_double_wave_sound():
	hit_ground_double_wave_sound.play()

func play_hit_ground_single_sound():
	hit_ground_double_sound.play()

func play_hit_ground_double_sound():
	hit_ground_double_sound.play()
	
func shake_cam():
	Global.current_camera.start_shake(0.5,10,30)
