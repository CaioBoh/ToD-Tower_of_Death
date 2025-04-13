extends Area2D

@onready var camera_2d: Camera2D = $"../../player/CameraGuide/Camera2D"

func _on_body_entered(body: Node2D) -> void:
	camera_2d.limit_right = 2400
	camera_2d.limit_left = 1585
	camera_2d.limit_bottom = -989
