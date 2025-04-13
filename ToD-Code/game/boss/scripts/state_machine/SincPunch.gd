extends State
@onready var animation_player = $"../../AnimationPlayer"
var attack_finished = false
@onready var left_hand = $"../../Left_Hand"
@onready var right_hand = $"../../Right_Hand"
const WAVE = preload("res://game/boss/scene/wave.tscn")
@onready var is_touching_floor = $"../../Left_Hand/isLeftTouchingFloor"
@export var wave_speed = 200
var throw_wave = false
var already_waved = false


func enter():
	throw_wave = false
	attack_finished = false
	already_waved = false
	super.enter()
	owner.set_physics_process(false)
	animation_player.play("SincPunch")
	#print("sinc punch!")
	
	
func exit():
	
	super.exit()
	#owner.set_physics_process(false)
	
func transition():
	if attack_finished:
		attack_finished = false
		get_parent().change_state("Idle")
		#print("Now its idling")
	if is_touching_floor.is_colliding() and not throw_wave:
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
	var new_wave_right = WAVE.instantiate()
	var new_wave_left = WAVE.instantiate()
	new_wave_right.position = right_hand.position
	new_wave_right.speed = wave_speed
	new_wave_right.scale.x = -1;
	new_wave_left.position = left_hand.position
	new_wave_left.speed = -wave_speed
	new_wave_left.position.y +=40
	new_wave_right.position.y +=40
	owner.add_child(new_wave_left)
	owner.add_child(new_wave_right)
