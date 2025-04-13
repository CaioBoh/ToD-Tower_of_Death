extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self,"modulate:a",0.0,0.6)
	await tween.finished
	queue_free()
