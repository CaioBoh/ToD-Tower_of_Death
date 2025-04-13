extends StaticBody2D

@onready var anim: AnimatedSprite2D = $texture
@onready var timer: Timer = $Timer
@onready var area_2d: Area2D = $Area2D
@onready var label = $Label

var is_open = false
var player
var player_in_range = false

func _ready():
	player = Global.global_player
	label.visible = false
	
func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact") and not is_open:
		open_chest()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player and not is_open:
		player_in_range = true
		label.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	label.visible = false


func open_chest():
	is_open = true
	anim.play("open")
	call_deferred("drop_itens")
	timer.start(1.5)

func drop_itens():
	var coin_scene = preload("res://game/map/coin/coin.tscn")
	var num_coins = 30
	for i in range(num_coins):
		var coin = coin_scene.instantiate()
		get_parent().add_child(coin)
		coin.position = position + Vector2(randf_range(-60,60),randf_range(-10,10))

func _on_timer_timeout() -> void:
	queue_free()
