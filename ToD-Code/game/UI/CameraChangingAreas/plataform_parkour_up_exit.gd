extends Area2D

@onready var camera_2d: Camera2D = $"../../player/CameraGuide/Camera2D"

func _on_body_entered(body: Node2D) -> void:
	camera_2d.limit_bottom = 100000000
	camera_2d.limit_right = 100000000
	camera_2d.limit_left = -100000000
