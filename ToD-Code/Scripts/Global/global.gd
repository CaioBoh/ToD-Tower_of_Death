extends Node

const DEATH_PARTICLE_ATLAS = preload("res://Scenes/Particles/death_particle_atlas.tscn")
const CROSS_HIT = preload("res://Scenes/Particles/cross_hit.tscn")
var cont_moedas: int = 0
var input_allowed := true
var global_player: CharacterBody2D
var current_camera: Camera2D
var key_picked: bool
var dash_picked: bool
var double_jump_picked: bool
var is_player_dead: bool = false
var max_player_health: int = 100
var player_health := max_player_health
var amount_of_collectibles := 3
var collectibles_collected: Array[bool]
var collectibles_found := 0
var initial_player_position : Vector2
var current_level_path : String
var first_time_spawning := true
var disable_physics := false

# ------------------------ #
# DEATH DIALOGUE VARIABLES #
# ------------------------ #

var death_encounters = 0;
var dead_count = 0;
var is_talking = false

func _ready():
	if first_time_spawning:
		first_time_spawning = false
	is_player_dead = false
	death_encounters = 0

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

func reset():
	is_talking = false
	is_player_dead = false
	first_time_spawning = true
	
func receive_upgrade(upgrade: String):
	match upgrade:
		"dash":
			dash_picked = true
		"double_jump":
			double_jump_picked = true
			
func game_over():
	is_player_dead = true
	dead_count+=1
	
func collect_coin():
	cont_moedas += 1
	
func on_upgrade_picked():
	input_allowed = false
	disable_physics = true
	global_player.velocity = Vector2(0, 0)
	global_player.animation_component.animation_player.play("receiving_dash")
	await global_player.animation_component.animation_player.animation_finished
	input_allowed = true
	disable_physics = false
