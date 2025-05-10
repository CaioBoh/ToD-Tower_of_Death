extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
var player

func _ready():
	player = Global.global_player

func _on_body_entered(body: Node2D) -> void:
	if body == player:
		body.collect_coin()
		get_coin()
	
func get_coin():
	queue_free()
