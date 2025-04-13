extends Node2D
@onready var horizontal = $Horizontal
@onready var vertical = $Vertical


func _ready():
	horizontal.emitting = true
	vertical.emitting = true
	await get_tree().create_timer(2,true,false,true).timeout
	queue_free()

func _process(delta):
	position = Global.global_player.global_position+Vector2(0,-20)
