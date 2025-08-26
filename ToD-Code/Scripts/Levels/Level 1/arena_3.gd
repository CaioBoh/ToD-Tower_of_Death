extends Node2D

@onready var summoners: Node2D = $Summoners
@onready var enemies: Node2D = $Enemies
@onready var spawn_timer: Timer = $SpawnTimer
@onready var enemy_spawn_trigger_3: Area2D = $"../enemy_spawn_trigger3"
@onready var timer_label: Label = get_tree().root.get_node("FirstLevel/HUD").timer_countdown_label

var started: bool = false
var finished: bool = false

func _process(delta: float) -> void:
	var arena_3_timer: Timer = $Arena3_Timer
	if not arena_3_timer.is_stopped():
		var time_left = "%.2f" %arena_3_timer.time_left
		timer_label.text = time_left

func _on_spawn_timer_timeout() -> void:
	spawn_timer.wait_time = 5
	for summoner in summoners.get_children(false):
		summoner.already_spawned = false
		summoner.spawn_enemy()

#func _on_enemy_spawn_trigger_3_body_entered(_body: Node2D) -> void:
#	enemy_spawn_trigger_3.get_node("CollisionShape2D").set_deferred("disabled", true)
#	spawn_timer.start()

func _on_dialogue_actionable_body_entered(body: Node2D) -> void:
	if body == Global.global_player:
		$"Dialogue Actionable".set_deferred("monitoring", false)
		var balloon = $"Dialogue Actionable".action()
		await balloon.dialogue_finished
		$Arena3_Timer.start()
		spawn_timer.start()
