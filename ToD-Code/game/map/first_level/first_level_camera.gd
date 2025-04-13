extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.current_camera = self
	
