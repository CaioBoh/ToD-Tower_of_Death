extends Node2D

var health = 100
var max_health = 100
var tremble_vect: Vector2 = Vector2.ZERO
var tremble_speed : float = 0
var position_dead : Vector2
var is_dead = false

@onready var hurt_sound: AudioStreamPlayer2D = $hurt_sound
@onready var health_bar: ProgressBar = $"HUD/CenterContainer/VBoxContainer/ProgressBar"
@export var lower_health_color: Color

@onready var hands = $Hands
@onready var sprite = $AnimatedSprite2D

signal dead

func _process(delta):
	color_based_on_health()
	if health <= 0 and not is_dead:
		health = 0
		is_dead = true
		dead.emit()
		await get_tree().create_timer(1).timeout
		position_dead = global_position
		$TrembleTimer.start()
	
	health_bar.value = health
	
func _physics_process(delta: float) -> void:
	if is_dead:
		global_position = global_position.move_toward(tremble_vect, tremble_speed * delta)
		if global_position.distance_to(tremble_vect) < 20:
			tremble_vect = position_dead + Vector2(randf_range(-20,20), randf_range(-20,20))
			
func color_based_on_health():
	if health > 0:
		var value = remap(health,0,max_health,0,1)
		sprite.modulate = lerp(lower_health_color,Color.WHITE,value)
		hands.modulate = lerp(lower_health_color,Color.WHITE,value)

func _on_hands_damaged():
	health -= Global.player_sword_damage
	hurt_sound.play()

func _on_tremble_timer_timeout():
	tremble_speed = 200
	tremble_vect = position_dead + Vector2(randf_range(-40,40), randf_range(-40,40))
