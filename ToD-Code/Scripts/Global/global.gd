extends Node

var global_player: CharacterBody2D
var current_camera: Camera2D
var key_picked: bool
var dash_picked: bool
var double_jump_picked: bool
var is_player_dead: bool = false
var max_player_health: int = 100
var player_health := max_player_health
var player_sword_damage = 10
var amount_of_collectibles := 3
var collectibles_collected: Array[bool]
var collectibles_found := 0
var initial_player_position : Vector2
var current_level_path : String
var first_time_spawning := true

# ------------------------ #
# DEATH DIALOGUE VARIABLES #
# ------------------------ #

var death_encounters = 0;
var dead_count = 0;
var is_talking = false

func change_time_scale_for_duration(timeScale, duration):
	Engine.time_scale = timeScale
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1
	
#Demo
func reset_demo():
	death_encounters = 0
	dead_count = 0
	is_talking = false
	key_picked = false
	dash_picked = false
	double_jump_picked = false
	is_player_dead = false
	player_health = 100
	player_sword_damage = 10

func reset():
	is_talking = false
	is_player_dead = false
	player_sword_damage = 10
	first_time_spawning = true
	
func receive_upgrade(upgrade: String):
	match upgrade:
		"dash":
			dash_picked = true
		"double_jump":
			double_jump_picked = true
