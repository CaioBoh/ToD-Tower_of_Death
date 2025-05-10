extends Node2D

var health = 100
var max_health = 100
var tremble_vect: Vector2 = Vector2.ZERO
var is_dead = false
@onready var hurt_sound: AudioStreamPlayer2D = $hurt_sound

@export var lower_health_color: Color

@onready var hands = $Hands
@onready var sprite = $AnimatedSprite2D

signal dead


func _process(delta):
	color_based_on_health()
	if health <= 0 and not is_dead:
		is_dead = true
		dead.emit()
		await get_tree().create_timer(2).timeout
		$TrembleTimer.start()
	position+=tremble_vect * delta
func color_based_on_health():
	if health > 0:
		var value = remap(health,0,max_health,0,1)
		sprite.modulate = lerp(lower_health_color,Color.WHITE,value)
		hands.modulate = lerp(lower_health_color,Color.WHITE,value)


func _on_hands_damaged():
	health-=Global.player_sword_damage
	hurt_sound.play()


func _on_tremble_timer_timeout():
	tremble_vect = Vector2(randf_range(-100,100), randf_range(-100,100))
	
