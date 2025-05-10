extends Area2D

@onready var camera_guide: Marker2D = $"../../player/CameraGuide"

func _on_body_entered(body: Node2D) -> void:
	if body == Global.global_player:
		camera_guide.offset_active = true
