extends Node2D

@onready var summoners: Node2D = $Summoners
@onready var enemies: Node2D = $Enemies
@onready var spawn_timer: Timer = $SpawnTimer
@onready var enemy_spawn_trigger_3: Area2D = $"../enemy_spawn_trigger3"

var started: bool = false
var finished: bool = false

func _on_spawn_timer_timeout() -> void:
	spawn_timer.wait_time = 5
	for summoner in summoners.get_children(false):
		summoner.already_spawned = false
		summoner.spawn_enemy()

func _on_enemy_spawn_trigger_3_body_entered(body: Node2D) -> void:
	enemy_spawn_trigger_3.get_node("CollisionShape2D").set_deferred("disabled", true)
	spawn_timer.start()
