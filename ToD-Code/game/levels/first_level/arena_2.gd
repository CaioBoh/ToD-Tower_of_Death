extends Area2D

signal arena_2_cleared

@onready var summoners: Node2D = $Summoners
@onready var enemies: Node2D = $Enemies
@onready var enemy_spawn_trigger_2: Area2D = $"../enemy_spawn_trigger2"

var started: bool = false
var finished: bool = false

func _process(_delta: float) -> void:
	if started and enemies.get_child_count(false) == 0 and not finished:
		finished = true
		arena_2_cleared.emit()

func _on_enemy_spawn_trigger_2_body_entered(_body: Node2D) -> void:
	for summoner in summoners.get_children(false):
		summoner.spawn_enemy()
	started = true
