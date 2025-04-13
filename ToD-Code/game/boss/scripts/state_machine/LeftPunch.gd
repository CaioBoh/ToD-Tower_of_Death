extends State


@onready var animation_player = $"../../AnimationPlayer"
@onready var left_hand = $"../../Left_Hand"
@onready var is_left_touching_floor = $"../../Left_Hand/isLeftTouchingFloor"

const WAVE = preload("res://game/boss/scene/wave.tscn")

var attack_finished = false
var wave_speed = 500
var throw_wave = false
var already_waved = false

func enter():
	attack_finished = false
	throw_wave = false
	already_waved = false
	super.enter()
	owner.set_physics_process(false)
	animation_player.play("LeftPunchTest")
	print("left punch!")
	
func exit():
	super.exit()
	#owner.set_physics_process(false)
	
func transition():
	if attack_finished:
		owner.set_physics_process(false)
		attack_finished = false
		get_parent().change_state("Idle")
		print("Now its idling")
	if is_left_touching_floor.is_colliding() and not throw_wave:
		throw_wave = true
		#print("is touching floor")
	if throw_wave and not already_waved:
		Global.current_camera.shake(0.5,10,30)
		#print("throwing a wave")
		already_waved = true
		throw_new_wave()

func _on_animation_player_animation_finished(anim_name):
	attack_finished = true


func throw_new_wave():
	var new_wave = WAVE.instantiate()
	new_wave.global_position = left_hand.global_position - Vector2(550, 0)
	new_wave.speed = wave_speed
	new_wave.acceleration = 600
	new_wave.scale.x = -1
	new_wave.position.y +=35
	new_wave.modulate = left_hand.modulate
	get_parent().owner.get_parent().add_child(new_wave)
