extends Area2D

@onready var actionable = $"../Death/Actionable"

func _on_body_entered(body: Node2D) -> void:
	Global.is_talking = false
	SceneTransition.change_scene("res://game/levels/first_level/first_level.tscn")
