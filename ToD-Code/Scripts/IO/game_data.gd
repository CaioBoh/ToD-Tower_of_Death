@tool
extends Resource
class_name GameData

@export var key_picked: bool
@export var dash_picked: bool
@export var double_jump_picked: bool
@export var player_health: int
@export var collectibles_collected: Array[bool]
@export var death_count: int
@export var death_encounters: int
@export var player_position: Vector2
@export var current_level_path: String
