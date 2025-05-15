extends Area2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"
@export var talkable: bool = true

const BALLOON = preload("res://Scenes/UI/Dialogue/balloon.tscn")

func action() -> Node:
	var balloon: Node = BALLOON.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource, dialogue_start)
	return balloon
