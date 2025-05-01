extends Node

var global_player: CharacterBody2D
var current_camera: Camera2D
var key_picked: bool = true
var dash_picked: bool = false
var is_player_dead: bool = false
var player_health: int = 100
var player_sword_damage = 10

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
	
func reset():
	death_encounters = 0
	dead_count = 0
	is_talking = false
	talked_first_time = false
	key_picked = true
	dash_picked = false
	is_player_dead = false
	player_health = 100
	player_sword_damage = 10
