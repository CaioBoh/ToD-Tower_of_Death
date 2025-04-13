extends State


@onready var animation_player = $"../../AnimationPlayer"
@onready var is_right_touching_floor = $"../../Right_Hand/isRightTouchingFloor"
@onready var right_hand = $"../../Right_Hand"

const WAVE = preload("res://game/boss/scene/wave.tscn")

var attack_finished = false
var throw_wave = false
var already_waved = false
var wave_speed = 500.0

func enter():
	attack_finished = false
	throw_wave = false
	already_waved = false
	super.enter()
	owner.set_physics_process(false)
	animation_player.play("MyLibrary/RightPunch")
	print("right punch!")
	
func exit():
	super.exit()
	#owner.set_physics_process(false)
	
func transition():
	if attack_finished:
		owner.set_physics_process(false)
		attack_finished = false
		get_parent().change_state("Idle")
		#print("Now its idling")
	if is_right_touching_floor.is_colliding() and not throw_wave:
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
	new_wave.global_position = right_hand.global_position - Vector2(470, 0)
	new_wave.speed = -wave_speed
	new_wave.acceleration = -600
	new_wave.position.y +=40
	get_parent().owner.get_parent().add_child(new_wave)
	
