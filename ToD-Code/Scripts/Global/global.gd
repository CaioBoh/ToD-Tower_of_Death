extends Node

var global_player: CharacterBody2D
var current_camera: Camera2D
var key_picked: bool = true
var dash_picked: bool = true
var double_jump_picked: bool = true
var is_player_dead: bool = false
var max_player_health: int = 100
var player_health := max_player_health
var player_sword_damage = 10
var collectibles_found = 0

# ------------------------ #
# DEATH DIALOGUE VARIABLES #
# ------------------------ #

var death_encounters = 0;
var dead_count = 0;
var is_talking = false
var talked_first_time: bool = false

func change_time_scale_for_duration(timeScale, duration):
	Engine.time_scale = timeScale
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1
	
#Demo
func reset_demo():
	death_encounters = 0
	dead_count = 0
	is_talking = false
	talked_first_time = false
	key_picked = false
	dash_picked = false
	double_jump_picked = false
	is_player_dead = false
	player_health = 100
	player_sword_damage = 10

func reset():
	#death_encounters = 0
	#dead_count = 0
	is_talking = false
	#talked_first_time = false
	#key_picked = true
	#dash_picked = true
	is_player_dead = false
	player_health = 100
	player_sword_damage = 10
	
func receive_upgrade(upgrade: String):
	match upgrade:
		"dash":
			dash_picked = true
		"double_jump":
			double_jump_picked = true
