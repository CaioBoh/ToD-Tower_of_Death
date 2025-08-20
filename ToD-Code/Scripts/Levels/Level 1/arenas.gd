extends Node

@onready var platform: AnimatableBody2D = $platform
@onready var platform_path_follower: PathFollow2D = $Path2D/PathFollow2D
@onready var floor_1: CollisionShape2D = $Floor/Floor1
@onready var floor_2: CollisionShape2D = $Floor/Floor2
@onready var floor_3: CollisionShape2D = $Floor/Floor3
@onready var platform_seeking_player: CollisionShape2D = $platform/player_seeker/CollisionShape2D
@onready var arena_3_timer: Timer = $Arena3/Arena3_Timer
@onready var arena_3_spawn_timer: Timer = $Arena3/SpawnTimer
@onready var camera: Camera2D = $"../player/CameraGuide/Camera2D"
@onready var enemy_summoners: Node = $Arena1/EnemySummoners
@onready var enemy_spawn_trigger_1: Area2D = $enemy_spawn_trigger1
@onready var arena_3_enemies: Node2D = $Arena3/Enemies
@onready var floors := [floor_1, floor_2, floor_3]

var arenas_cleared = 0;
var current_platform_status: PlatformStatus
const platform_path_progress_per_arena = [0.167, 0.449, 0.714, 0.999]

enum PlatformStatus { WAITING, STOP, UP }

func _ready() -> void:
	floor_1.disabled = true
	floor_2.disabled = true
	floor_3.disabled = true

func _physics_process(_delta: float) -> void:
	check_platform()

func check_platform():
	platform.global_position = platform_path_follower.global_position
	if current_platform_status == PlatformStatus.UP:	
		if platform_path_follower.progress_ratio <= platform_path_progress_per_arena[arenas_cleared]:
			platform_path_follower.progress_ratio += 0.001
		else:
			platform_path_follower.progress_ratio = platform_path_progress_per_arena[arenas_cleared]
			Global.global_player.input_allowed = true
			current_platform_status = PlatformStatus.STOP
			if arenas_cleared != 3:
				floors[arenas_cleared].disabled = false
				platform_seeking_player.disabled = true
				if arenas_cleared == 2:
					$"Arena3/Dialogue Actionable".set_deferred("monitoring", true)
				print($"floor %d turned on", arenas_cleared + 1)
			else:
				self.set_physics_process(false)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == Global.global_player:
		if current_platform_status == PlatformStatus.WAITING:
			move_player_to_platform_center()

func _on_arena_1_arena_1_cleared() -> void:
	arenas_cleared = 1
	current_platform_status = PlatformStatus.WAITING
	platform_seeking_player.disabled = false
	print("arena 1 cleared")

func _on_arena_2_arena_2_cleared() -> void:
	arenas_cleared = 2
	current_platform_status = PlatformStatus.WAITING
	platform_seeking_player.disabled = false
	print("arena 2 cleared")

func _on_arena_3_timer_timeout() -> void:
	arenas_cleared = 3
	
	for enemy in arena_3_enemies.get_children(false):
		if enemy.has_method("hurt"):
			enemy.hurt(Global.global_player, enemy.health)
			
	arena_3_spawn_timer.stop()
	current_platform_status = PlatformStatus.WAITING
	platform_seeking_player.disabled = false
	print("arena 3 cleared")
	
func move_player_to_platform_center():
	Global.global_player.input_allowed = false
	Global.global_player.knockback_vector = Vector2(0, 0)
	Global.global_player.velocity.x = 0
	while not Global.global_player.is_on_floor():
		await get_tree().create_timer(0.05).timeout
		
	var direction = Global.global_player.global_position.direction_to(platform_seeking_player.global_position).x
	direction /= abs(direction)
	Global.global_player.looking_direction = int(direction)
	Global.global_player.velocity.x = Global.global_player.looking_direction * Global.global_player.SPEED
	while abs(Global.global_player.global_position.x - platform_seeking_player.global_position.x) > 10:
		await get_tree().create_timer(0.05).timeout
	
	Global.global_player.position.x = platform_seeking_player.global_position.x
	Global.global_player.velocity.x = 0
	Global.global_player.animation.flip_h = false
		
	current_platform_status = PlatformStatus.UP
