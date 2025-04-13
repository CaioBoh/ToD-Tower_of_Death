extends Node2D

@export var ghost_scene: PackedScene
@export var sprite: AnimatedSprite2D
@export var color: Color

func start_spawn():
	$Timer.start()
func stop_spawn():
	$Timer.stop()


func _on_timer_timeout():
	var ghost_instance = ghost_scene.instantiate()
	get_tree().get_current_scene().add_child(ghost_instance)
	ghost_instance.global_position = sprite.global_position
	ghost_instance.texture = sprite.sprite_frames.get_frame_texture(sprite.animation,sprite.frame)
	ghost_instance.self_modulate = color
	ghost_instance.scale = sprite.scale
	ghost_instance.flip_h = sprite.flip_h
	ghost_instance.z_index = -1
	#print("ghost spawned!")
