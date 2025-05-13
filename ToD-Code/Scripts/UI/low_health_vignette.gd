extends Control

@export var vignette_jump_timer : Timer
var vignette_amount := 0.0
var vignette_increase := 0.0
var vignette_amount_increase_per_frame := 0.05
var vignette_max_jump_timer_wait_time := 3.0
var vignette_max_jump_time := 0.8

const vignette_max_increase := 0.5

func _process(delta: float) -> void:
	material.set_shader_parameter("MainAlpha", vignette_amount + vignette_increase)

func _ready() -> void:
	Global.global_player.health_changed.connect(change_low_health_vignette)
	vignette_jump_timer.start()
	
func change_low_health_vignette():
	vignette_amount = 0.5 * (1 - clamp(float(Global.player_health) / (Global.max_player_health / 2), 0, 1))
	
func _on_vignette_jump_timer_timeout() -> void:
	if Global.player_health <= Global.max_player_health / 2:
		while(vignette_increase < vignette_max_increase):
			await get_tree().create_timer(0.05).timeout
			vignette_increase += vignette_amount_increase_per_frame
			
		vignette_increase = vignette_max_increase
		
		await get_tree().create_timer(vignette_max_jump_time * \
		clamp((float(Global.player_health) / (Global.max_player_health / 3)), 0.4, 1)).timeout
		
		while(vignette_increase > 0):
			await get_tree().create_timer(0.05).timeout
			vignette_increase -= vignette_amount_increase_per_frame
			
		vignette_increase = 0
	
	vignette_jump_timer.wait_time = vignette_max_jump_timer_wait_time * \
	clamp(pow((float(Global.player_health) / (Global.max_player_health / 2)), 2), 0.05, 1)
	vignette_jump_timer.start()
