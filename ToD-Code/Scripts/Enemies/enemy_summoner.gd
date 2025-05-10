extends Marker2D

enum Enemies{NONE, STANDING, FLYING }

@export var enemy_type: Enemies

var already_spawned = false

const FLYING_ENEMY = preload("res://Scenes/Enemies/flying_enemy.tscn")
const STANDING_ENEMY = preload("res://Scenes/Enemies/standing_enemy.tscn")


func spawn_enemy() -> void:
	#print("enemy spawned")
	if already_spawned:
		return
	var instance
	if enemy_type == Enemies.NONE:
		return
	if enemy_type == Enemies.STANDING:
		instance = STANDING_ENEMY.instantiate()
	if enemy_type == Enemies.FLYING:
		instance = FLYING_ENEMY.instantiate()
	instance.global_position = global_position
	print("enemy spawned")
	already_spawned = true
	get_parent().get_parent().get_node("Enemies").add_child(instance)
