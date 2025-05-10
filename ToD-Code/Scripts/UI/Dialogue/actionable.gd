extends Area2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

const BALLOON = preload("res://Scenes/UI/Dialogue/balloon.tscn")

func action() -> void:
	var balloon: Node = BALLOON.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource, dialogue_start)
