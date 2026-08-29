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
var MAX_PLAYER_HEALTH: int = 100
var player_health := MAX_PLAYER_HEALTH
var amount_of_collectibles := 3
var collectibles_collected: Array[bool]
var collectibles_found := 0
var initial_player_position : Vector2
var current_level_path : String
var first_time_spawning := true
var disable_physics := false
var signal_id := 0

signal returned_to_menu

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

func wait_safely(signal_to_wait: Signal):
	var signal_received = [false]
	var safe_signal_name = "safe_signal_" + str(signal_id)
	signal_id += 1
	add_user_signal(safe_signal_name)

	var connect_to_generic_signal = func(...args):
		if not signal_received[0]:
			signal_received[0] = true
			Global.emit_signal(safe_signal_name)
				
	if is_instance_valid(signal_to_wait.get_object()):
		signal_to_wait.connect(connect_to_generic_signal)
	else:
		emit_signal(safe_signal_name)
		
	returned_to_menu.connect(connect_to_generic_signal)

	var safe_signal = Signal(self, safe_signal_name)
	
	await safe_signal
	
	if is_instance_valid(signal_to_wait.get_object()):
		signal_to_wait.disconnect(connect_to_generic_signal)
	returned_to_menu.disconnect(connect_to_generic_signal)
	remove_user_signal(safe_signal_name)

func change_time_scale_for_duration(timeScale, duration):
	Engine.time_scale = timeScale
	await wait_safely(get_tree().create_timer(duration, true, false, true).timeout)
	Engine.time_scale = 1

func reset_game():
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
	await wait_safely(global_player.animation_component.animation_player.animation_finished)
	input_allowed = true
	disable_physics = false
