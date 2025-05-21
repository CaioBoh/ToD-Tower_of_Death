extends Area2D

@onready var camera_2d: Camera2D = $"../../player/CameraGuide/Camera2D"
@export var zoom: Vector2 = Vector2(1, 1)

func _on_body_entered(body: Node2D) -> void:
	if body == Global.global_player:
		create_tween().tween_property(camera_2d, "zoom", zoom, 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		
func _on_body_exited(body: Node2D) -> void:
	if body == Global.global_player:
		create_tween().tween_property(camera_2d, "zoom", Vector2(1.5, 1.5), 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
