extends Node
class_name player_dash_component

@export var ghost_spawner : Node2D
@export var dash_sound : AudioStreamPlayer
@export var dash_timer : Timer

var dashed_on_air := false
var is_dash_timer_finished := true

@export var KNOCKBACK_DASH : float = 2000.0
@export var DASH_DURATION : float = 0.2
@export var GHOST_SPAWNING_INTERVAL : float = 0.2

func handle_dash(physics_component : player_physics_component, is_on_floor : bool):
	if is_on_floor:
		dashed_on_air = false
	if Global.disable_physics or not Global.input_allowed:
		return
	var can_dash := Global.dash_picked and is_dash_timer_finished and not dashed_on_air
	if Input.is_action_just_pressed("dash") and can_dash:
		var knockback := Vector2(physics_component.looking_direction * KNOCKBACK_DASH, 0)
		physics_component.apply_knockback(knockback, DASH_DURATION)
			
		if not is_on_floor:
			dashed_on_air = true
		
		dash_sound.play()
		is_dash_timer_finished = false
		dash_timer.start()
		
		await spawn_dash_ghosts()
		
func spawn_dash_ghosts():
	ghost_spawner.start_spawn()
	await get_tree().create_timer(GHOST_SPAWNING_INTERVAL).timeout
	ghost_spawner.stop_spawn()
	
func _on_dash_timer_timeout():
	is_dash_timer_finished = true
