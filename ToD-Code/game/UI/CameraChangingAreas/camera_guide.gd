extends Marker2D

@onready var player: CharacterBody2D = $".."
@export var offset_active = false

func _process(delta: float) -> void:
	if offset_active:
		Global.current_camera.position_smoothing_speed = 2
		if player.velocity.x > 0:
			#await get_tree().create_timer(.4).timeout
			global_position = player.global_position + Vector2(250,-100)
		if player.velocity.x < 0:
			#await get_tree().create_timer(.4).timeout
			global_position = player.global_position + Vector2(-250,-100)
			
	else:
		global_position = player.global_position
		Global.current_camera.position_smoothing_speed = 5
	
