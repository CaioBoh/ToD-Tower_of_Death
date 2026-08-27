extends Node
class_name player_dash_component

@export var KNOCKBACK_DASH: float = 2000
@export var DASH_DURATION: float = 0.2
@export var GHOST_SPAWNING_INTERVAL: float = 0.2
@export var ghost_spawner: Node2D
@export var dash_sound: AudioStreamPlayer
@export var dash_timer: Timer

var dashed_on_air: bool = false
var is_dash_timer_finished: bool = true

func handle_dash(physics_component: player_physics_component, is_on_floor: bool):
	if is_on_floor: dashed_on_air = false
	
	var can_dash: bool = Global.dash_picked and is_dash_timer_finished and not dashed_on_air
	can_dash = can_dash and not Global.disable_physics and Global.input_allowed and not Debug.no_clip
	
	if not Input.is_action_just_pressed("dash") or not can_dash:
		return

	if not is_on_floor: dashed_on_air = true
	
	dash(physics_component)

func dash(physics_component: player_physics_component):
	var knockback := Vector2(physics_component.looking_direction * KNOCKBACK_DASH, 0)
	physics_component.apply_knockback(knockback, DASH_DURATION)
	dash_sound.play()
	is_dash_timer_finished = false
	dash_timer.start()
	
	spawn_dash_ghosts()
	
func spawn_dash_ghosts():
	ghost_spawner.start_spawn()
	await get_tree().create_timer(GHOST_SPAWNING_INTERVAL).timeout
	ghost_spawner.stop_spawn()
	
func _on_dash_timer_timeout():
	is_dash_timer_finished = true
