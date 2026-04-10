extends Node

@export var index: int

var collected = false

func _ready() -> void:
	if Global.collectibles_collected[index]:
		queue_free()

func _on_actionable_body_entered(body: Node2D) -> void:
	if body == Global.global_player and not collected:
		collected = true
		Global.collectibles_found += 1
		var balloon = $Actionable.action()
		await balloon.dialogue_finished
		Global.collectibles_collected[index] = true
		queue_free()
