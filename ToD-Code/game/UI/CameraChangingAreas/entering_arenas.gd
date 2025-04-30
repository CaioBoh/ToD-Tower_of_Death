extends Area2D

@onready var camera_guide: Marker2D = $"../../player/CameraGuide"
@onready var camera_2d: Camera2D = $"../../player/CameraGuide/Camera2D"

func _on_body_entered(_body: Node2D) -> void:
	camera_guide.offset_active = false
	camera_2d.limit_bottom = 590
	camera_2d.limit_right = -528
	camera_2d.limit_left = -2182
